# -*- coding: utf-8 -*-

import requests;

cookie_str='route=fe207c8a23a8c55f8a14b32a664aace4; JSESSIONID=028F2769195A743937D6254915D7B853.wjvsmvpca01vsmscm01'
start_dt = '2020-07-01'
end_dt = '2020-08-31'
account = '1914201105'

if account == '1914201103':
    region = '华东江西'
    buid = 16
elif account == '1914201102':
    region = '华东'
    buid = 16
elif account == '1914201105':
    region = '华北'
    buid = 12
elif account == '1914201104':
    region = '西北'
    buid = 13
elif account == '1914201106':
    region = '乐购'
    buid = 31

print(account,region)

path = 'D:/Projects/CRV/验收单退货单'
home = 'https://vss.crv.com.cn/scm'
userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko'
#验收单
header = {'Content-Type': 'text/xml;charset=utf-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': 'https://vss.crv.com.cn/scm/scm/receipt/receipt_vender_search.jsp?cmid=0',   ##这个很重要，少了报错
          'Cookie': cookie_str,
          'Origin': 'https://vss.crv.com.cn',
          'User-Agent':userAgent,
          'Host': 'vss.crv.com.cn'
          }
#url='https://vss.crv.com.cn/scm/DaemonSCMSheet?clazz=Receipt4Scm&operation=search&editdate_min=2020-07-01&editdate_max=2020-08-31&status=0&venderid=1914201103&buid=16&timestamp=1599468118141&&timestamp=1599468118141'
yanshoudan_url ='{}/DaemonSCMSheet?clazz=Receipt4Scm&operation=search&editdate_min={}&editdate_max={}&venderid={}&buid={}&timestamp=1599466307112&&timestamp=1599466307112'.format(home
                                                                                                                                                                                            ,start_dt
                                                                                                                                                                                            ,end_dt
                                                                                                                                                                                            ,account
                                                                                                                                                                                            ,buid)
print(yanshoudan_url)

ysd = '{}/验收单_{}{}_{}-{}.xml'.format(path,region,account,start_dt,end_dt)
re = requests.get(yanshoudan_url,headers=header)
print(re.status_code)
#print(re.text)
with open(ysd,'w',encoding='utf-8') as ysd:
    ysd.write(re.text)

yanshoudan_mx = '{}/DaemonMain?cmid=3020303000&operation=search&service=UnpaidSheet&sheettype=2301&buid={}&venderid={}&docdate_min={}&docdate_max={}&&timestamp=1599467081076&&timestamp=1599467081076'.format(home
                                                                                                                                                                                                               ,buid
                                                                                                                                                                                                               ,account
                                                                                                                                                                                                               ,start_dt
                                                                                                                                                                                                               ,end_dt)
print(yanshoudan_mx)
header = {'Content-Type': 'text/xml;charset=utf-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': 'https://vss.crv.com.cn/scm/main/unpaidsheet.jsp?cmid=3020303000',   ##这个很重要，少了报错
          'Cookie': cookie_str,
          'User-Agent':userAgent,
          'Host': 'vss.crv.com.cn'
          }
ysdmx = '{}/验收单明细_{}{}_{}-{}.xml'.format(path,region,account,start_dt,end_dt)
re = requests.get(yanshoudan_mx,headers=header)
print(re.status_code)
#print(re.text)
with open(ysdmx,'w',encoding='utf-8') as ysdmx:
    ysdmx.write(re.text)

tuihuodan_list = '{}/DaemonSCMSheet?clazz=Ret4Scm&operation=search&retdate_min={}&retdate_max={}&venderid={}&buid={}&timestamp=1599530046933&&timestamp=1599530046933'.format(home
                                                                                                                                                                              ,start_dt
                                                                                                                                                                              ,end_dt
                                                                                                                                                                              ,account
                                                                                                                                                                              ,buid
                                                                                                                                                                              )
print(tuihuodan_list)
header = {'Content-Type': 'text/xml;charset=utf-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': 'https://vss.crv.com.cn/scm/scm/ret/ret_vender_search.jsp?cmid=0',   ##这个很重要，少了报错
          'Cookie': cookie_str,
          'User-Agent':userAgent,
          'Host': 'vss.crv.com.cn'
          }
thdlb = '{}/退货单列表_{}{}_{}-{}.xml'.format(path,region,account,start_dt,end_dt)
re = requests.get(tuihuodan_list,headers=header)
print(re.status_code)
#print(re.text)
with open(thdlb,'w',encoding='utf-8') as thdlb:
    thdlb.write(re.text)