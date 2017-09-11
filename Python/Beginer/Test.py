
#
# lin=[12,34]
# print (lin)
# lin
# print ("Hello world")
# print('hello world')
# import this

#print many lines
# s="""
# this is
# text
# with
# many lines
# """
# print(s)

# set
# a ={1,2,4,5}
# b={3,4,5,6}
# print(a-b)
# print(a&b)
# print(a|b)
# print (a^b)

#进程
# import os
# print(os.getpid())
# print(os.getcwd())
#
# import scipy
# import jupyter

# 1. 计算给出两个时间之间的时间差

import datetime as dt
# current time
cur_time = dt.date.today()
print(cur_time)
print(dt.datetime.today())
# one day
pre_time = dt.date(2016, 5, 20) # eg: 2016.5.20
print (pre_time)
delta = cur_time - pre_time
# if you want to get discrepancy in days
print (delta.days)
# # if you want to get discrepancy in hours
# print (delta.hours)
# # and so on
#
# 2. 获取n天前的时间
cur_time = dt.datetime.now()
# previous n days
pre_time = dt.timedelta(days=1)

# 3. 将给定的时间精确到天或者其他单位
cur_time = dt.now()
# get day of current time
cur_day = cur_time.replace(hour=0, minute=0, second=0, mircrosecond=0)

# # 4. 获取一连串的时间序列（返回list）
# cur_time = dt.datetime.today()
# datelist = [cur_time - dt.timedelta(days=x) for x in range(0, 100)]
# # 或者
# import pandas as pd
# datelist = pd.date_range(pd.datetime.today(), periods=100).tolist()
#
# # 5. 将时间字符串转化为datetime类型
# date_format = "%Y-%m-%d" # year-month-day
# time = dt.strptime('2016-06-22', date_format)
#
# # 6. 将时间类型转化为字符串类型
# time_str = dt.strftime("%Y-%m-%d", dt.now()) # return like "2016-06-22"
