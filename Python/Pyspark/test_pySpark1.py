from pyspark.sql import SparkSession
from pyspark.sql import Row
 
if __name__ == '__main__':
    spark = SparkSession\
        .builder\
        .appName("loadTextData")\
        .master("local[*]")\
        .getOrCreate()
    lines = spark.sparkContext.textFile("./input/people.txt")
    parts = lines.map(lambda line: line.split(" "))
    people = parts.map(lambda p: Row(name=p[0], age=p[1]))
    peopledf = spark.createDataFrame(people)
    peopledf.show()
    # +---+----+
    # |age|name|
    # +---+----+
    # | 27|Jack|
    # | 24|Rose|
    # | 32|Andy|
    # +---+----+
    peopledf.createOrReplaceTempView("people")
    namedf = spark.sql("select name from people where age < 30")
    namedf.show()
    # +----+
    # |name|
    # +----+
    # |Jack|
    # |Rose|
    # +----+
    spark.stop()
