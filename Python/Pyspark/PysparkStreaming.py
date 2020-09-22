#!/usr/bin/evn python
# -*- coding:utf-8 -*-

from pyspark.sql import SparkSession
from pyspark.streaming import StreamingContext
from pyspark.sql import functions

ss=SparkSession.builder.appName('NetWordcount').getOrCreate()
ss.setLogLevel("WARN")


sss= StreamingContext(ss,5)

lines = sss.socketTextStream("localhost",9999)
words = lines.flatMap(lambda l:l.split(' '))
wordcount=words.map(lambda word:(word,1)).reduceByKey(add)
wordcount.map(lambda x:(x[0],x[1])).pprint()

sss.start()

sss.awaritTermination()




