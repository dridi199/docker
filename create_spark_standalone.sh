
num_worker=$1

rm -r spark_*

# Vérifie si un argument est fourni
if [ -z "$num_worker" ]; then
  echo "Usage: $0 <num_worker>"
  exit 1
fi

# Vérifie si l'argument est un entier
if ! [[ "$num_worker" =~ ^[0-9]+$ ]]; then
  echo "Erreur: L'argument doit être un entier."
  exit 1
fi

# Vérifie si l'argument est inférieur à 5
if [ "$num_worker" -ge 5 ]; then
  echo "Erreur: L'argument doit être un entier inférieur à 5."
  exit 1
fi

echo "creating spark directories"
mkdir spark_master
mkdir spark_slave
mkdir spark_datastore

echo "creating data store for master and workers"
echo "#Spark Datastore
FROM ubuntu:latest

RUN apt-get update

VOLUME [\"/data\"]

ENTRYPOINT [\"/bin/true\"]
" >>  spark_datastore/dockerfile
echo "datastore dockerfile created"

echo "building datastore"
cd spark_datastore
docker build -t spark-datastore:datastore .
echo "build success"
echo "creating /data for datastore"
docker create -v /data --name spark-datastore spark-datastore:datastore
cd ..

echo "create the spark master container"

echo "
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \\
    wget \\
    openjdk-17-jre-headless \\
    python3 \\
    scala && cd /home && mkdir spark && cd spark && \\
    wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \\
    tar -xvf spark-3.5.1-bin-hadoop3.tgz

# Setup JAVA_HOME and SPARK_HOME -- useful for docker commandline
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
ENV SPARK_HOME=/home/spark/spark-3.5.1-bin-hadoop3
ENV PATH=\"\$SPARK_HOME/bin:\$PATH\"


# Fix certificate issues
RUN apt-get update && \\
    apt-get install ca-certificates-java && \\
    apt-get clean && \\
    update-ca-certificates -f

RUN export PATH

ENTRYPOINT [\"/home/spark/spark-3.5.1-bin-hadoop3/bin/spark-class\",\"org.apache.spark.deploy.master.Master\"]
" >> spark_master/dockerfile

cd spark_master
echo "build spark_master container"
docker build -t spark-master:master .
echo "build success"

echo "run master"
docker run -d -p 8080:8080 -p 7077:7077 --volumes-from spark-datastore --name master spark-master:master
echo  "done"


echo "create workers"
cd ..
echo "
# SPARK Slave
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \\
    wget \\
    openjdk-17-jre-headless \\
    python3 \\
    scala && apt-get clean && cd /home && mkdir spark && cd spark && \\
    wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \\
    tar -xvf spark-3.5.1-bin-hadoop3.tgz

# Setup JAVA_HOME and SPARK_HOME -- useful for docker commandline
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
RUN export JAVA_HOME
ENV SPARK_HOME=/home/spark/spark-3.5.1-bin-hadoop3
RUN export SPARK_HOME

ENV PATH=\"\$SPARK_HOME/bin:\$PATH:\$SPARK_HOME/bin/spark-class\"
RUN export PATH

ENV CORES=3
ENV MEMORY=2G

# Fix certificate issues
RUN apt-get update && \\
    apt-get install ca-certificates-java && \\
    apt-get clean && \\
    update-ca-certificates -f


ENTRYPOINT \$SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker -c \$CORES -m \$MEMORY \$MASTER_PORT_7077_TCP_ADDR:\$MASTER_PORT_7077_TCP_PORT
" >> spark_slave/dockerfile

cd spark_slave

# Boucle sur les valeurs de 1 à num_executor
for i in $(seq 1 $num_worker ); do
  echo "build worker $i"
  docker build -t spark-worker:worker$i .
  echo "run and link worker $i to the master"
  docker run -d --link master:master --volumes-from spark-datastore spark-worker:worker$i
done

echo "everything roll"

