#to run a Python job using spark-submit :

` 
spark-submit \
  --master spark://spark-master-ip:7077 \
****************** Optional S3 section start *****************
 --conf spark.hadoop.fs.s3a.endpoint=http://s3-ip-adress:9000 \
  --conf spark.hadoop.fs.s3a.access.key=access_key \
  --conf spark.hadoop.fs.s3a.secret.key=secret_key \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
****************** Optional S3 section end *******************
  --driver-memory 1G \
  --executor-memory 1G \
  --executor-cores 1 \
  MainPython.py 
`
