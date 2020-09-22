# -*- coding: utf-8 -*-

import http.cookiejar as cookielib
import requests
import os, sys, time
import pytesseract   #导入识别验证码信息包
from PIL import Image
import re
from selenium import webdriver  #引入浏览器驱动
from selenium.webdriver.common.action_chains import ActionChains  # 引入 ActionChains 类进行鼠标事情操作
#from .utils.log import logger    引入日志模块
import random    # 导入 random(随机数) 模块

'''
Cookie -> yzm.jpg -> yzm
'''
now_milli_timestamp = int(round(time.time() * 1000))

crvURL = 'https://vss.crv.com.cn'
logonURL = crvURL+'/scm/logon/logon.jsp'
imgURL = crvURL+'/scm/DaemonCode?timestamp='+str(now_milli_timestamp)
crvCrackHome = 'D:/Projects/CRV/Crack'
crvCookie = '{}/cookies.txt'.format(crvCrackHome)
imgCookie = '{}/imgcookies.txt'.format(crvCrackHome)
crvYZMjpg = '{}/yzm.jpg'.format(crvCrackHome)

# session代表某一次连接
crvSession = requests.session()
#crvSession.cookies.clear_session_cookies()

print('session cookie at beginning',crvSession.cookies.get_dict())
# 因为原始的session.cookies 没有save()方法，所以需要用到cookielib中的方法LWPCookieJar，这个类实例化的cookie对象，就可以直接调用save方法。
#crvSession.cookies = cookielib.LWPCookieJar(filename="Cookies.txt")
#print(crvSession.cookies)

homePage = crvSession.get(url=logonURL)
print('session cookie after homepage:',crvSession.cookies.get_dict())
#crvSession.cookies.save(filename=crvCookie)

#imgSession = requests.session()
#imgSession.cookies = cookielib.LWPCookieJar(filename=crvCookie)
#imgSession.cookies.save(filename=imgCookie)

userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko'
header = {'Referer':logonURL,
          'Connection':'keep-alive',
          'User-Agent':userAgent,
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Host': 'vss.crv.com.cn'
          }
print(imgURL)
img = crvSession.get(imgURL, headers=header, allow_redirects=True, stream=True)

print('crv session after get img:', crvSession.cookies.get_dict())
img2 = crvSession.get(imgURL, headers=header, allow_redirects=True, stream=True)

#print(img.headers)
##wb 写入二进制图片
with open(crvYZMjpg, 'wb') as file:
    file.write(img2.content)

##用pytesseract解析下载的图片
imageObject = Image.open(crvYZMjpg)
yzm = pytesseract.image_to_string(imageObject).replace(" ", "")   #解析并去除空格
#print(imageObject)
print(len(yzm))
print('YZM recoganized as:',yzm)


'''
yzm -> logon -> pull
'''
#crvSession.cookies.save(filename=imgCookie)
#print(str(crvSession.cookies))
#print(re.findall(r'(?:JSESSIONID|route)=\S+',str(crvSession.cookies)))
dlCookieStr = str.join(',', re.findall(r'(?:JSESSIONID|route)=\S+',str(crvSession.cookies)))
print(dlCookieStr)
now_milli_timestamp = int(round(time.time() * 1000))
dlURL ='{}/scm/DaemonLogonVender?site=0&action=logon&checkcode={}&timestamp={}&&timestamp={}'.format(crvURL
                                                                                                     ,yzm.strip()
                                                                                                     ,now_milli_timestamp
                                                                                                     ,now_milli_timestamp)

print(dlURL)
account = '161914201102'
password = 'Fu123456'
#crvSession = requests.session()
#crvSession.cookies = cookielib.LWPCookieJar(filename=imgCookie)

header = {'Content-Type': 'text/plain;charset=UTF-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': logonURL,   ##这个很重要，少了报错
          'Origin': 'https://vss.crv.com.cn',
          'User-Agent':userAgent,
          'Cookie':dlCookieStr,
          'Host': 'vss.crv.com.cn',
          'Content-Length': '146'
          }
#print(header)
postData = {
    "logonid": account,
    "password": password,
    'timestamp': now_milli_timestamp
}

postDataxml = '<xdoc><head><logonid>{}</logonid><password>{}</password><timestamp>{}</timestamp></head></xdoc>'.format(account
                                                                                                                       ,password
                                                                                                                       ,now_milli_timestamp
                                                                                                                       )
print(postDataxml)
denglu = requests.post(url=dlURL, data=postDataxml, headers=header)
print('crv session after get post yzm:',crvSession.cookies)
print(denglu.request.headers)
# 无论是否登录成功，状态码一般都是 statusCode = 200
print(f"statusCode = {denglu.status_code}")
print(f"text = {denglu.text}")
with open('D:/Projects/CRV/Crack/response.txt', 'wb') as file:
    file.write(denglu.content)





crvSession.close()

header = {'Content-Type': 'text/xml; charset=UTF-8',
          'Connection':'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'zh-Hans-CN, zh-Hans; q=0.8, en-US; q=0.5, en; q=0.3',
          'Referer': 'https://vss.crv.com.cn/scm/scm/receipt/receipt_vender_search.jsp?cmid=0',   ##这个很重要，少了报错
          'Cookie': 'route=2ab699eeeaf0e359d5c65f5d363bc2cc; JSESSIONID=7FF3390CCF9FB350B799E591C6704E46.wjvsmvpca01vsmscm01',
          'Origin': 'https://vss.crv.com.cn',
          'User-Agent':userAgent,
          'Host': 'vss.crv.com.cn'
          }
url='https://vss.crv.com.cn/scm/DaemonSCMSheet?clazz=Receipt4Scm&operation=search&editdate_min=2020-08-01&editdate_max=2020-09-02&status=0&venderid=1914201106&buid=31&timestamp=1599461979975&&timestamp=1599461979975'
re = requests.get(url,headers=header)
#print(re.text)

#driver = webdriver.Chrome(executable_path='D:/Tools/ChromeDriver/chromedriver.exe')
#driver.get('https://www.qixin.com/')
'''
from PIL import Image
import random          #导入 random(随机数) 模块
import pytesseract     #导入识别验证码信息包
import time

#截图，裁剪图片并返回验证码图片名称
# _save_url 保存路径 ；yuansu 验证码元素标识
def image_cj(driver,_save_url,yuansu):
    try:
        _file_name = random.randint(0, 100000)
        _file_name_wz = str(_file_name) + '.png'
        _file_url = _save_url + _file_name_wz
        driver.get_screenshot_as_file(_file_url)  # get_screenshot_as_file截屏
        captchaElem = driver.find_element_by_id(yuansu)  # # 获取指定元素（验证码）
        # 因为验证码在没有缩放，直接取验证码图片的绝对坐标;这个坐标是相对于它所属的div的，而不是整个可视区域
        # location_once_scrolled_into_view 拿到的是相对于可视区域的坐标  ;  location 拿到的是相对整个html页面的坐标
        captchaX = int(captchaElem.location['x'])
        captchaY = int(captchaElem.location['y'])
        # 获取验证码宽高
        captchaWidth = captchaElem.size['width']
        captchaHeight = captchaElem.size['height']

        captchaRight = captchaX + captchaWidth
        captchaBottom = captchaY + captchaHeight

        imgObject = Image.open(_file_url)  #获得截屏的图片
        imgCaptcha = imgObject.crop((captchaX, captchaY, captchaRight, captchaBottom))  # 裁剪
        yanzhengma_file_name = str(_file_name) + '副本.png'
        imgCaptcha.save(_save_url + yanzhengma_file_name)
        return yanzhengma_file_name
    except Exception as e:
        print('错误 ：', e)



# 获取验证码图片中信息（保存地址，要识别的图片名称）
def image_text(_save_url,yanzhengma_file_name):
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files (x86)\Tesseract-OCR\tesseract'
    yanzhengma_file_url = 'F:\\Python\\workspace\\selenium_demo3_test\\test\\case\\PT\\'+ _save_url
    image = Image.open(yanzhengma_file_url + yanzhengma_file_name)
    text = pytesseract.image_to_string(image)
    print('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$图片中的内容为：', text)
    return text



#截图并写入验证码（保存地址，验证码元素，验证码输入框元素）
def jietu_xieru(driver,_save_url,yuansu,yanzhma_text):
    # 截图当前屏幕，并裁剪出验证码保存为:_file_name副本.png，并返回名称
    yanzhengma_file_name = image_cj(driver,_save_url, yuansu)  ##对页面进行截图，弹出框宽高（因为是固定大小，暂时直接写死了）
    # 获得验证码图片中的内容
    text = image_text(_save_url, yanzhengma_file_name)
    # 写入验证码
    driver.find_element_by_id('verfieldUserText').send_keys(text)
    time.sleep(2)

from selenium import webdriver  #引入浏览器驱动
import time
from selenium.webdriver.common.action_chains import ActionChains  # 引入 ActionChains 类进行鼠标事情操作
import pytesseract   #导入识别验证码信息包
from PIL import Image
#from .utils.log import logger    引入日志模块
import random    # 导入 random(随机数) 模块
from selenium_demo3_test.utils.file import *   #引入下载图片函数所在的py文件
from selenium_demo3_test.utils.image import *   #引入图片操作
from  selenium_demo3_test.utils.llqi import *   #引入浏览器操作
#coding=utf-8


driver = llq_qudong('Chrome')
open_url(driver,'http://www.cncaq.com/')

denlu =driver.find_element_by_id('top_login_a')  #根据id获取登录元素
ActionChains(driver).click(denlu).perform()   #点击登录,打开弹出层
driver.find_element_by_id('loginNameText').send_keys('188XXXXXXXX')
driver.find_element_by_id('passwordText').send_keys('111111')
time.sleep(2)

#截图裁剪出验证码，并写入验证码输入框中（保存地址，验证码元素，验证码输入框元素）
jietu_xieru(driver,'img\\login\\','imgvercodeLogin','verfieldUserText')
driver.find_element_by_xpath('//*[@id="loginForm"]/div[6]/button').click()  #点击登录

_user_name = driver.find_element_by_xpath('//*[@id="userWrap"]/div/p').get_attribute('innerHTML')
user_name = '用户1'
#判断不相等，则未登录成功，则为验证码输入错误（此时，只考虑验证码，且图文识别并非百分之百正确）一直循环读取验证码输入
while _user_name != user_name:
    jietu_xieru(driver, 'img\\login\\', 'imgvercodeLogin', 'verfieldUserText')
    driver.find_element_by_xpath('//*[@id="loginForm"]/div[6]/button').click()  # 点击登录
    _user_name = driver.find_element_by_xpath('//*[@id="userWrap"]/div/p').get_attribute('innerHTML')
else:
    print('#############################################登录成功#############################################')
    pass    
'''