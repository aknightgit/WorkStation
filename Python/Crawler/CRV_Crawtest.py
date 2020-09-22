# -*- coding: utf-8 -*-

import requests;
import sys;
import time;
import datetime;

#reload(sys)

## pull date range
today=datetime.date.today()
startdate=today-datetime.timedelta(90)
enddate=today-datetime.timedelta(1)
now_timestamp=time.time()
now_milli_timestamp = int(round(time.time() * 1000))
##print('Pulling data from',startdate,'to',enddate,'...')
print(now_milli_timestamp)

#
venderid='1914201105'
cmid='3020303000'
crvurl='https://vss.crv.com.cn/scm/DaemonMain'
xmlres=r"C:\Users\admin\Downloads\crv.xml"

response = requests.get(url=crvurl,
                        params={'cmid':cmid
                            ,'service':'UnpaidSheet'
                            ,'sheettype':'2301'
                            ,'operation':'search'
                            ,'docdate_min':startdate
                            ,'docdate_max':enddate
                            ,'venderid':venderid
                            ,'buid':'12'
                            ,'timestamp':now_milli_timestamp},
                        headers={'Content-Type':'text/xml;charset=UTF-8',
                                 'Referer':'https://vss.crv.com.cn/scm/main/unpaidsheet.jsp?cmid=3020303000',
                                 'Cookie':'route=6caf1caac92d5d9198bada11f4884cef; JSESSIONID=6BF2F2B1A8DB6DC79B5BF30AD3DFFA14.wjvsmvpca01vsmscm01',
                                 'Connection':'keep-alive',
                                 'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36'
                                 }
                        )
#print(response.text);
with open(xmlres,'w') as xm:
    xm.write(response.text)

