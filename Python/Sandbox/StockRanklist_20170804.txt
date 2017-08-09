import urllib.request
url='http://quote.stockstar.com/stock/ranklist_a_3_1_1.html'  #目标网址
headers={"User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64)"}  #伪装浏览器请求报头
request=urllib.request.Request(url=url,headers=headers)  #请求服务器
response=urllib.request.urlopen(request)  #服务器应答
content=response.read().decode('gbk')   #以一定的编码方式查看源码
print(content)  #打印页面源码