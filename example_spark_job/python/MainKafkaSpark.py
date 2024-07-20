from pyspark.sql import SparkSession

spark = (SparkSession
         .builder
         .appName("Streaming from Kafka")
         .config("spark.streaming.stopGracefullyOnShutdown", True)
         .config('spark.jars.packages', 'org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.1')
         .config("spark.sql.shuffle.partitions", 4)
         .master("local[*]")
         .getOrCreate()
         )
ds1 = (spark.readStream
                    .format("kafka")
                    .option("kafka.bootstrap.servers", "localhost:9092")
                    .option("subscribe", "my-topic")
                    .option("startingOffsets", "earliest")
                    .load()
      )

query = ds1.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)") \
    .writeStream \
    .format("console") \
    .option("checkpointLocation", "path/to/HDFS/dir") \
    .start()

query.awaitTermination()
