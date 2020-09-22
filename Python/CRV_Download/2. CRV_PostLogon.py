from io import BytesIO

import requests
import time

account='131914201104'
password='Fu123456'
# yzm='X#NC'
# dlCookieStr = 'route=2ab699eeeaf0e359d5c65f5d363bc2cc; JSESSIONID=F5266A85E96DA3C29FB469D888E4A503.wjvsmvpca01vsmscm01'
# crvURL = 'https://vss.crv.com.cn'
# logonURL = crvURL+'/scm/logon/logon.jsp'
# now_milli_timestamp = int(round(time.time() * 1000))
userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko'
# postDataxml = '<xdoc><head><logonid>{}</logonid><password>{}</password><timestamp>{}</timestamp></head></xdoc>'.format(account
#                                                                                                                        ,password
#                                                                                                                        ,now_milli_timestamp
#                                                                                                                        )

# now_milli_timestamp = int(round(time.time() * 1000))
# dlURL ='{}/scm/DaemonLogonVender?site=0&action=logon&checkcode={}&timestamp={}&&timestamp={}'.format(crvURL
#                                                                                                      ,yzm.strip()
#                                                                                                      ,now_milli_timestamp
#                                                                                                      ,now_milli_timestamp)
#
# header = {'Content-Type': 'text/plain;charset=UTF-8',
#           'Connection':'keep-alive',
#           'Accept-Encoding': 'gzip, deflate, br',
#           'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
#           'Referer': logonURL,   ##这个很重要，少了报错
#           'Origin': 'https://vss.crv.com.cn',
#           'User-Agent':userAgent,
#           'Cookie':dlCookieStr,
#           'Host': 'vss.crv.com.cn',
#           'Content-Length': '146',
#           'Sec-Fetch-Dest': 'empty',
#           'Sec-Fetch-Mode': 'cors',
#           'Sec-Fetch-Site': 'same-origin'
#           }
# #print(header)
#
# print(postDataxml)
# print(header)
# denglu = requests.post(url=dlURL, data=postDataxml, headers=header)
# print(denglu.text)
# print(denglu.status_code)
#


from PIL import Image
# from selenium import webdriver
#
# driver = webdriver.Chrome()
# driver.maximize_window()
# driver.implicitly_wait(6)
#
# driver.get(logonURL)
# time.sleep(2)
# driver.refresh() # 刷新方法 refresh

print('模拟')
now_milli_timestamp = int(round(time.time() * 1000))

crvURL = 'https://vss.crv.com.cn'
logonURL = crvURL+'/scm/logon/logon.jsp'
imgUrl = crvURL+'/scm/DaemonCode?timestamp='+str(now_milli_timestamp)
print(logonURL)
print(imgUrl)
header = {'Referer':logonURL,
          'Connection':'keep-alive',
          'User-Agent':userAgent,
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Host': 'vss.crv.com.cn'
          }
s=requests.session()
s.cookies.clear_session_cookies()
new=s.get(logonURL)
img=s.get(imgUrl, headers=header, stream=True)
print(new.headers)
print(img.headers)

with open('D:/Projects/CRV/Crack/yzm2.jpg', 'wb') as file:
    file.write(img.content)

code=input()
now_milli_timestamp = int(round(time.time() * 1000))
loginUrl ='{}/scm/DaemonLogonVender?site=0&action=logon&checkcode={}&timestamp={}&&timestamp={}'.format(crvURL
                                                                                                     ,code
                                                                                                     ,now_milli_timestamp
                                                                                                     ,now_milli_timestamp)
# print(loginUrl)
now_milli_timestamp = int(round(time.time() * 1000))
postDataxml = '<xdoc><head><logonid>{}</logonid><password>{}</password><timestamp>{}</timestamp></head></xdoc>'.format(account
                                                                                                                       ,password
                                                                                                                       ,now_milli_timestamp
                                                                                                                       )
print(postDataxml)
header = {'Content-Type': 'text/plain;charset=UTF-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': logonURL,   ##这个很重要，少了报错
          'Origin': 'https://vss.crv.com.cn',
          'User-Agent':userAgent,
          'Host': 'vss.crv.com.cn',
          'Content-Length': '146',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin'
          }
rs=s.post(loginUrl,data=postDataxml,headers=header)
print(rs.url)
print(rs.text)
print(rs.request.headers)
print(rs.status_code)
s.cookies.clear_session_cookies()
s.close()