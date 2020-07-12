#!usr/local/bin/python
# -*- coding:utf-8 -*-

import sys
from pyspark.sql import SparkSession
from operator import add

def wordCountFunc(file):
	'''
	reduceByKey() = groupByKey().mapValues()
	groupByKey just combine all values together without doing anything
	
	from pyspark.sql import SparkSession
	'''
	ss=SparkSession.builder.appName("wordCountUsing").config('spark.default.parallelism',20).getOrCreate()
	webtr=ss.read.option("header","true").csv(sys.argv[1]).rdd.map(lambda x:(x[2],1))
	
	wt=webtr.reduceByKey(add).sortBy(lambda x:x[1],False).collect()
	print "Word\t\t\tCount"
	for i,j in wt:
		print("%s\t\t\t%d" % (i,j))
	ss.stop()

if __name__ == "__main__":
	if(len(sys.argv)!=2):
		print("Missing parameter: <file>. Usage: %s <file>" % (sys.argv[0]))
		exit(-1)
	wordCountFunc(sys.argv[1])