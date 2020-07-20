#!/usr/local/bin/python
# -*- coding:utf-8 -*-
 
import sys
from pyspark.sql import SparkSession
from operator import add
#file=sys.args[1]

def WordCount1(file):
	"""
	reduceByKey, (k,v) only
	build record as (record,1) and do add/+
	if using add, need 
	from operator import add
	"""
	
	ss=SparkSession.builder.appName('wordCount1').config('spark.default.parallelism',24).getOrCreate()
	ual=ss.read.text(sys.argv[1]).rdd
	ual=ual.map(lambda l:l[0]).map(lambda x:x.split("\t")).map(lambda x:(x[7],x[16])).flatMap(lambda x:x)

	#ual.take(30)

	wc=ual.map(lambda x:(x,1)).reduceByKey(lambda a,b:a+b).sortBy(lambda x:int(x[1]),False).collect()

	print "Word:\t\t\tCounts"
	for j,i in wc:
		print "%s:\t\t\t%d" % (j,i)
	ss.stop()
	
if __name__ ==  "__main__":
	if (len(sys.argv)!=2):
		print("Usage: %s <file>" % sys.argv[0])
		exit(-1)
	WordCount1(sys.argv[1])

