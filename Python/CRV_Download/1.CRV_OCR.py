# -*- coding: utf-8 -*-

import requests;
import sys;
import time;
import datetime;

#reload(sys)

'''
pull date range
'''
today = datetime.date.today()
startdate = today-datetime.timedelta(90)
enddate = today-datetime.timedelta(1)
#now_timestamp=time.time()
now_milli_timestamp = int(round(time.time() * 1000))
##print('Pulling data from',startdate,'to',enddate,'...')
print(now_milli_timestamp)

urlGETimage = 'https://vss.crv.com.cn/scm/DaemonCode?timestamp={}'.format(now_milli_timestamp)
print(urlGETimage)
response = requests.get(url=urlGETimage)