#!//bin/env python
# -*- coding:utf-8 -*-

import sys
import os
reload(sys)
sys.setdefaultencoding("utf-8")   ## set the default runtime encoding for this session
from pyspark.sql import SparkSession
from operator import add
from pyspark.sql import functions

## must set spark.sql.catalogImplementation=hive, so that table can be saved in hive db
ss=SparkSession.builder.appName('FootBall').config('spark.default.parallelism','8').config('spark.sql.catalogImplementation','hive').getOrCreate()
ss.conf.set("spark.sql.legacy.allowCreatingManagedTableUsingNonemptyLocation","true") ## allow overwrite existing table

player=ss.read.option('header','True').csv('./input/FootballPlayer/FootballPlayer.csv').rdd

player.cache()


logtxt="/home/hadoop/pySpark/output.txt"
topPlayer="/home/hadoop/pySpark/topPlayer.txt"
player_byClub='/home/hadoop/pySpark/player_byClub.txt'
errtxt="/home/hadoop/pySpark/error.txt"

try:
	##data input partitions
	p_par=player.getNumPartitions()
	with open(logtxt,'w') as f:
		f.write("Input partitions: %d\n" % p_par)

	##total player count
	tot_cnt=player.count()
	with open(logtxt,'a') as f:
		f.write("Total player Count: %d\n" % tot_cnt)

	##total clubs, club list
	clubs=player.map(lambda x:x[9]).distinct()
	clubs_cnt=clubs.count()
	#clubs_cnt2=clubs.reduce()
	
	#player by clubs
	'''
	need to filter all the None returns, to avoid NoneType has no attribute encode error.
	'''
	play_by_club=player.map(lambda x:(x[9],1)).filter(lambda x:x[0] is not None).reduceByKey(add).sortBy(lambda x:x[1],ascending=False).collect()
	#print(play_by_club)
	player_by_club=player.map(lambda x:(x[9],1)).filter(lambda x:x[0] is not None).countByKey()
	#print(type(play_by_club))
	#print(play_by_club)
	#print(type(player_by_club))
	#print(player_by_club)
	with open(player_byClub,'a') as f:
		f.write("Clubs count : %d\n" % clubs_cnt)
		#for i in sorted(clubs.collect()):
		#	f.write(i+'\n')
		#f.write(play_by_club)
		print '-------------------1 print collect list`'
		for cl in play_by_club:
			#print(cl[0].encode('utf-8'),cl[1])
			c,p=cl[0].encode('utf-8'),str(cl[1])
			f.write(c+'\t'+p+'\n')
		print '-------------------2 print dict pairs'
		f.write('----------------------------------------------------------------')
		for cl,pl in sorted(player_by_club.items(),key=lambda x:x[1],reverse=True):
			f.write(cl.encode('utf-8')+'==========>\t'+str(pl)+'\n')
	

	'''
	Spark SQL
	'''

	plDF=player.toDF()
	play_basicDF=plDF.select('ID','Name','Age','Club','Nationality','Overall','Value','Wage','Position','Height','Weight')
	play_attrDF=plDF.select('ID','Crossing','Dribbling','ShortPassing','Finishing','LongShots','LongPassing','BallControl')
	
	##overall 85 above, by nationaly, club
	##alias need to add ''
	play_basicDF.where(play_basicDF.Overall>85).groupBy(play_basicDF.Nationality).\
agg(functions.count(play_basicDF.ID).alias('play_cnt'),functions.max(play_basicDF.Overall).alias('Highest'),functions.avg(play_basicDF.Overall).alias('Average'),functions.avg(play_basicDF.Age).alias('Avg_Age')).\
select('Nationality','play_cnt','Highest','Average','Avg_Age').orderBy(functions.desc('play_cnt')).show(50)
	### encode issue dont know why
	#play_basicDF.where(play_basicDF.Overall>85).groupBy(play_basicDF.Club).agg(functions.max(play_basicDF.Overall).alias('Highest'),functions.count(play_basicDF.ID).alias('Players'),functions.avg(play_basicDF.Overall).alias('AVG_Age')).orderBy(functions.desc('Players')).show(50)
	#play_basicDF.where(play_basicDF.Overall>85).groupBy(play_basicDF.Club).\
#agg(functions.count(play_basicDF.ID).alias('Players'),functions.max(play_basicDF.Overall).alias('Highest'),functions.avg(play_basicDF.Age).alias('Avg_Age')).\
#select('Club'.encode('utf-8'),'Players','Highest','Avg_Age').orderBy(functions.desc('Players')).show(50)
	
	#ascending= is a must
	topPlayers=play_basicDF.join(play_attrDF,'ID',"inner").select('Name','Age','Overall','Club','Nationality','Value','Wage','Position','Finishing','BallControl').where("Overall>=90").sort('Overall',ascending=False)
	topPlayers.coalesce(1)  ## repartition
	topPlayers.write.format('json').mode('overwrite').save("./output/topPlayer")
	with open(topPlayer,'w') as ft:
		ft.write('=================TopPlayers===========')
		ft.write(str(topPlayers.show()))

	##overwrite table recreate

	## cannot read from hive
	topPlayers.write.format('orc').mode('overwrite').saveAsTable('topPlayers')
	#try format.hive . This one work, table can be read
	topPlayers.write.format('hive').mode('overwrite').saveAsTable('myhive.topPlayers')
	ss.sql("select *from topPlayers")
	
	#register table . SQL test
	print "This is Spark SQL PART"
	play_basicDF.registerTempTable('plb')
	play_attrDF.registerTempTable('pla')
#	ss.sql("select case when Overall >=90 then '>90' when Overall >=85 and Overall<90 then '85~89' when Overall >=80 and Overall <85 then '80~84' else '<80' end as Rating,Age,count(1) as Players group by Rating,Age order by Rating,Age") 

	ss.sql("select case when Overall >=90 then '90~' \
when Overall >=85 and Overall<90 then '85~89' \
when Overall >=80 and Overall <85 then '80~84' else '50~80' end as Rating \
,Age,count(1) as Players \
from plb group by Rating,Age \
order by Rating DESC,Age").show(100)


except TypeError as te:
	with open(errtxt,'w') as fe:
		fe.write(str(te)+'\n') ##mind that write accept only 1 argv
		fe.write(te.message+'\t same way to output error message \n')
		fe.write('\t'.join(te.args))

except Exception as e:
	with open(errtxt,'w') as fe:
		fe.write(e.message+'\n')
		fe.write(str(e))
else:
	print("------------------------------JOB Succeed!!----------------------")
finally:
	ss.stop()
	print("Done~~~~~~~~~~~~~~~~~`")
