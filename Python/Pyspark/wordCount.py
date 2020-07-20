#!usr/bin/env python
# encoding:utf-8
from __future__ import print_function
 
 
'''
__Author__:沂水寒城
功能：基于 Spark 的 wordcount 实例
'''
 
 
 
 
import sys
from operator import add
from pyspark.sql import SparkSession
 
 
def wordCountFunc(para):
    '''
    词频统计函数 
    '''
    spark=SparkSession.builder.appName("PythonWordCount").getOrCreate()
    lines=spark.read.text(para).rdd.map(lambda r: r[0])
    counts=lines.flatMap(lambda x: x.split(' ')).map(lambda x: (x, 1)).reduceByKey(add)
    output=counts.collect()
    for (word, count) in output:
        print("%s: %i" % (word, count))
    spark.stop()
 
 
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: wordcount <file>", file=sys.stderr)
        exit(-1)
    wordCountFunc(sys.argv[1])
    
