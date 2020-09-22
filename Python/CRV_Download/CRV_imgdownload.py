# -*- coding: utf-8 -*-

import requests
import time
from selenium import webdriver
import random    # 导入 random(随机数) 模块
from selenium import *   #引入下载图片函数所在的py文件

logon_url = 'https://vss.crv.com.cn/scm/logon/logon.jsp'

#driver = webdriver.Chrome()
#driver.maximize_window()
#webdriver.get(logon_url)

#img_url = driver.find_element_by_id('img_checkcode').get_attribute('src')
#print(img_url)

response = requests.get(url=logon_url,
                        headers={'Content-Type': 'text/html;charset=UTF-8',
                                 'Connection':'keep-alive',
                                 'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36'
                                 })
print(response.content)
'''
yanzhengma_src = driver.find_element_by_id('imgvercodeLogin').get_attribute('src')  #根据验证码img的id获得元素，并使用get_attribute方法得到图片的地址
img_url = yanzhengma_src+'.png'        #根据上图看到，我当前的地址 /52结尾，所以，我这边添加后缀，方便稍后下载
file_name = random.randint(0, 100000)  #生成一个100000以内的随机数
file_path = 'img\\login'               #下载验证码图片的时候的保存地址，默认为当前脚本运行目录下的file_path文件夹中
save_img(img_url, file_name,file_path) #下载图片（调用的其它文件中已经写好的下载方法）_要下载的文件路径，保存的文件名，保存路径
'''

''' ##download png/img
import requests  # http客户端
import os  # 创建文件夹
from PIL import Image

os.makedirs('./image/', exist_ok=True)
IMAGE_URL = "http://jwgl.cqjtu.edu.cn/jsxsd/verifycode.servlet?t=0.33489178693749055"


def request_download():
    r = requests.get(IMAGE_URL)
    with open('./image/img.png', 'wb') as f:
        f.write(r.content)


try:
    request_download()
    print('download img')
    im = Image.open('./image/img.png')
    im.show()
except:
    print('download img error!')
'''