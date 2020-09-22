
import os
import sqlite3

username = os.environ.get('USERNAME')
cookie_file = r'C:\Users\{UserName}\AppData\Local\Google\Chrome\User Data\Default\Cookies'.format(UserName=username)
print(cookie_file)

domain_name = 'vss.crv.com.cn'

con = sqlite3.connect(cookie_file, timeout=10)
cursor = con.cursor()

#cursor.execute('SELECT host_key, name, value, path, expires_utc, is_secure, encrypted_value '
#                        'FROM cookies WHERE host_key like "%{}%";'.format(domain_name))

cursor.execute('SELECT * FROM cookies')
for description in cursor.description:
    print(description[0])

con.commit()
cursor.close()
