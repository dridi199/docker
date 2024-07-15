from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('PythonExample').getOrCreate()

list = [("Finance",10), 
        ("Marketing",20), 
        ("Sales",30), 
        ("IT",40) 
      ]

targetColumns = ["list_name","list_id"]
deptDF = spark.createDataFrame(data=list, schema = targetColumns)
deptDF.printSchema()
deptDF.show(truncate=False)
