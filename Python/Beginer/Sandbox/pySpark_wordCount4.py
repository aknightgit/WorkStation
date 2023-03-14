#!/usr/local/bin/python
# -*- coding:utf-8 -*-

import sys
from pyspark.sql import SparkSession
from operator import add

def wordCountFunc(para):
	'''
	countByKey do the group-count-collect
	'''
	ss=SparkSession.builder.appName("CountBy").getOrCreate()
	wbt=ss.read.option("header","true").csv(sys.argv[1]).rdd.map(lambda x:x[2])
	
	wbth=wbt.countByValue()
	
	#for k in sorted(wbth.keys()):
	#	print("%s\t\t\t%s" % (k,wbth[k]))
	print "sort by values reversely"
	for k,v in sorted(wbth.items(),key=lambda i:i[1],reverse=True):
		print("%s\t\t\t%s" % (k,v))
	ss.stop()
	
	

if __name__ == "__main__":
	if(len(sys.argv)!=2):
		print("Usage:%s <file>" % sys.argv[0])
	try:
		wordCountFunc(sys.argv[1])
	except:
		print "dull"
	finally:
		print "Job End successfully"
	