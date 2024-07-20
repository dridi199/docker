## to run a Python job using spark-submit :

``` 
spark-submit \
  --master spark://spark-master-ip:7077 \
<!-- Optional S3 section start -->
 --conf spark.hadoop.fs.s3a.endpoint=http://s3-ip-adress:9000 \
  --conf spark.hadoop.fs.s3a.access.key=access_key \
  --conf spark.hadoop.fs.s3a.secret.key=secret_key \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
<!-- Optional S3 section end -->
  --driver-memory 1G \
  --executor-memory 1G \
  --executor-cores 1 \
  MainPython.py 
```
## to run a Python Spark StreamingConsumer :

### Need to install kafka using compose for example from this tutoriel:

```
1- https://medium.com/@amberkakkar01/getting-started-with-apache-kafka-on-docker-a-step-by-step-guide-48e71e241cf2
2- then produce some message on the topic you create
3- then plugin you MainKafkaStream.py on your borker
4- enjoy...

### Resume
* install kafka using compose
* then use this command to create your topic using this command :
    docker exec -it <kafka-container-id> /opt/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic my-topic
* after that produce some message on your topic using this :
   docker exec -it <kafka-container-id> /opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-topic
* the last thing is to run your job python using spark-submit command :
 spark-submit /home/docker/example_spark_job/python/MainKafkaSpark.py

Notice: to find the <kafka-container-id> after do the docker compose up call docker ps to see the container-id of kafka

```
