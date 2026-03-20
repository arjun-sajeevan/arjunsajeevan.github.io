from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

# 1. THE BRAIN: Initialize Spark with Kafka support
# Note: Spark needs a special "connector" (package) to talk to Kafka
spark = SparkSession.builder \
    .appName("RetailStreamAnalysis") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.13:3.5.0") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

# 2. THE SCHEMA: Defining the template for our JSON "envelopes"
schema = StructType([
    StructField("InvoiceNo", StringType(), True),
    StructField("StockCode", StringType(), True),
    StructField("Description", StringType(), True),
    StructField("Quantity", IntegerType(), True),
    StructField("UnitPrice", DoubleType(), True),
    StructField("CustomerID", StringType(), True),
    StructField("Country", StringType(), True)
])

# 3. THE CONNECTION: "Read" from the Kafka Post Office
raw_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092") \
    .option("subscribe", "retail-transactions") \
    .option("startingOffsets", "latest") \
    .load()

# 4. THE TRANSFORMATION: Unpack the JSON bytes into a Table
# Kafka sends data as 'value', so we convert that 'value' using our Schema
json_df = raw_df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*")

# 5. THE ACTION: Print the live table to the terminal
query = json_df.writeStream \
    .outputMode("append") \
    .format("console") \
    .start()

print("PySpark is waiting for the stream... Start the Producer now!")
query.awaitTermination()