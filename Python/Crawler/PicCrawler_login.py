
from selenium import webdriver
import time
import urllib.request
from bs4 import BeautifulSoup
import html.parser


def main():
    # *********  Open chrome driver and type the website that you want to view ***********************
    options = webdriver.ChromeOptions()
    options.add_experimental_option("excludeSwitches", ["ignore-certificate-errors"])
    driver = webdriver.Chrome(chrome_options=options)
    # driver = webdriver.Chrome()   # 打开浏览器

    # 列出来你想要下载图片的网站

    # driver.get("https://www.zhihu.com/question/35931586") # 你的日常搭配是什么样子？
    # driver.get("https://www.zhihu.com/question/61235373") # 女生腿好看胸平是一种什么体验？
    # driver.get("http://www.mayabbb.com/viewthread.php?tid=2117624&extra=page%3D1") # 腿长是一种什么体验？
    # driver.get("https://www.zhihu.com/question/19671417") # 拍照时怎样摆姿势好看？
    driver.get("http://www.mayabbb.com/viewthread.php?tid=2117564&extra=page%3D1") # 女性胸部过大会有哪些困扰与不便？
    # driver.get("https://www.zhihu.com/question/46458423") # 短发女孩要怎么拍照才性感？
    # driver.get("https://www.zhihu.com/question/26037846") # 身材好是一种怎样的体验？


    # 通过用户名密码登陆
    driver.find_element_by_name("username").send_keys("cnmqsbmaya")
    driver.find_element_by_name("password").send_keys("123456")

    # 勾选保存密码
    driver.find_element_by_name("loginsubmit").click()
    time.sleep(3)

    # ****************   Prettify the html file and store raw data file  *****************************************

    result_raw = driver.page_source # 这是原网页 HTML 信息
    result_soup = BeautifulSoup(result_raw, 'html.parser')
    # print(result_soup)
    result_bf = result_soup.prettify() # 结构化原 HTML 文件
    # print(result_bf)
    with open("C:/AK/Home/logdir/raw_result.txt", 'w',encoding='utf-8') as girls: # 存储路径里的文件夹需要事先创建。
        girls.write(result_bf)
    girls.close()
    print("Store raw data successfully!!!")


    # ****************   Store meta data of imgs  *****************************************
    # img_soup = BeautifulSoup(noscript_all, 'html.parser')
    img_nodes = result_soup.find_all('img',string="nddimg")
    with open("C:/AK/Home/logdir/img_meta.txt", 'w',encoding='utf-8') as img_meta:
        count = 0
        for img in img_nodes:
            if img.get('src') is not None:
                img_url = img.get('src')

                line = str(count) + "\t" + img_url  + "\n"
                img_meta.write(line)
                urllib.request.urlretrieve(img_url, "C:/AK/Home/storage/" + str(count) + ".jpg") # 一个一个下载图片
                count += 1
                time.sleep(1)

    img_meta.close()
    print("Store meta data and images successfully!!!")

if __name__ == '__main__':
    main()