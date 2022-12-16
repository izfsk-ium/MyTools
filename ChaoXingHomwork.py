import base64
from getpass import getpass
from http import cookiejar
from pprint import pprint
from re import sub
from typing import List
import requests
from bs4 import BeautifulSoup

URL_LOGIN = "http://passport2.chaoxing.com/fanyalogin"

session = requests.Session()
session.cookies = cookiejar.LWPCookieJar(
    filename='chaoxing_cookies.txt')
user_personal_id = ''
headers = {
    'Origin': 'http://passport2.chaoxing.com',
    'Referer': 'http://passport2.chaoxing.com/login?loginType=3&newversion=true&fid=-1&refer=http%3A%2F%2Fi.chaoxing.com',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.104 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest',
    'Host': 'passport2.chaoxing.com',
}
course_headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'Connection': 'keep-alive',
    'Host': 'mooc1-2.chaoxing.com',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 8.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36 Edg/85.0.564.51'
}


def login_and_get_subjects(username: str, password: str):

    payload = {
        "fid": "-1",
        "uname": username,
        "password": base64.b64encode(password.encode()).decode(),
        'refer': 'http%3A%2F%2Fi.chaoxing.com',
        't': 'true',
        'forbidotherlogin': '0',
    }
    resp = session.post(url=URL_LOGIN, headers=headers, data=payload)
    if resp.json()['status'] == True:
        # save cookie to cookie jar
        subject_list = list()
        homepage = session.get(
            "http://mooc2-ans.chaoxing.com/visit/courses/list")
        sp = BeautifulSoup(homepage.text, 'html.parser')
        for i in sp.select('a[target="_blank"]'):
            if i.text.strip() == '':
                continue
            subject_list.append(
                {'name': i.text.strip(), 'link': i.attrs['href']})
        return subject_list
    else:
        print(resp.json()["msg2"])
        return []


def get_real_task(url: str) -> list:
    res = session.get(url, headers=course_headers)
    ast = BeautifulSoup(res.text, 'html.parser')
    return [{
        'name': i.select('.overHidden2')[0].text,
        'status':i.select('.status')[0].text
    } for i in ast.select('.right-content')]


def main():
    username = input("Input Username (Typically phone number):")
    password = getpass("Password:")
    print('Starting Login...')
    for subject in login_and_get_subjects(username, password):
        res = session.get(
            subject['link'], headers=course_headers,
            allow_redirects=False)
        subject_detail_page = session.get(
            res.headers['Location'].replace('pageHeader=-1', 'pageHeader=8'))
        ast = BeautifulSoup(subject_detail_page.text, 'html.parser')
        courseId = ast.select('#courseid')[0].attrs['value']
        clazzId = ast.select('#clazzid')[0].attrs['value']
        cpi = ast.select('#cpi')[0].attrs['value']
        enc = ast.select('#workEnc')[0].attrs['value']
        sbj_name = ast.select('dd')[0].attrs['title']
        real_subject_task_url = 'http://mooc1.chaoxing.com/mooc2/work/list?courseId=%s&classId=%s&cpi=%s&ut=s&enc=%s' % (
            courseId, clazzId, cpi, enc
        )
        print('='*16)
        print(sbj_name)
        [print(' -[%5s]%s' % (i['status'], i['name']))
         for i in get_real_task(real_subject_task_url)]


main()
