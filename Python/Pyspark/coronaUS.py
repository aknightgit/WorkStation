#/usr/local/env python
# -*- coding:utf-8 -*-

import sys
import os
reload(sys)
sys.setdefaultencoding('utf-8')
from operator import add
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.window import Window    ##needed by window func

output='/home/hadoop/pySpark/uscol.out'
ss=SparkSession.builder.appName('CoronaUS').config('spark.default.parallelism','20').config('spark.sql.catalogImplementation','hive').\
config('spark.sql.legacy.allowCreatingManagedTableUsingNonemptyLocation','true').getOrCreate()

colus=ss.read.option('header','true').csv('./input/CoronaUS/us-counties.csv')
#colus.show()
colus.count()
before=colus.rdd.getNumPartitions()
after=colus.coalesce(1).rdd.getNumPartitions()
print('=========={} to {}=========='.format(before,after))
with open(output,'w') as op:
	op.write('{} to {}\n'.format(before,after))

try:
	colusbymonth=colus.groupBy(colus.date[0:7].alias('month'),colus.county,colus.state).agg(max(colus.cases).alias('totcases'),max(colus.deaths).alias('totdeaths')).orderBy(desc('month'))
	cbm=colusbymonth.groupBy(colusbymonth.month).agg(sum(colusbymonth.totcases),sum(colusbymonth.totdeaths)).orderBy(desc('month'))
	with open(output,'a') as op:
		op.write('{} partitions before coalesce\n'.format(cbm.rdd.getNumPartitions()))
	cbm.coalesce(1)
	with open(output,'a') as op:
		op.write('{} partitions in colusbymonth============='.format(cbm.rdd.getNumPartitions()))
	cbm.write.format('hive').mode('overwrite').saveAsTable('myhive.USCoronabyMonth')

	cbs=colusbymonth.where("month='2020-07'").groupBy(colusbymonth.state).agg(sum(colusbymonth.totcases),sum(colusbymonth.totdeaths)).orderBy(desc('sum(totdeaths)'))
	cbsr=cbs.withColumn('Rate',cbs['sum(totdeaths)']/cbs['sum(totcases)']).withColumn('CaseRank',row_number().over(Window.orderBy(desc('sum(totcases)')))).orderBy(desc('sum(totdeaths)'))
	cbsr.write.format('hive').mode('overwrite').saveAsTable('myhive.USCoronabyState')

	

except Exception as e:
	print('failed:------------------> {}'.format(e.message))
else:
	print('----------------------Job succeed!!!!!!!!!!!!!!!!!!')




s.stop()
