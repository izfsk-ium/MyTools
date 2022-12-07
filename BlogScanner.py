import socket
import pprint
import requests
import os
import itertools
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor
import json

buf = (
    "GET / HTTP/1.1\r\n"
    "Host: {HOST}\r\n"
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101 Firefox/52.0\r\n"
    "\r\n"
)  # HTTP请求

found = []


def scanner(ip_addr: str):
    sck = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sck.settimeout(1.0)
        sck.connect((ip_addr, 80))
        sck.send(buf.format(HOST=ip_addr).encode())
        recv = sck.recv(4096).decode()
        if recv.__len__() != 0:
            req = requests.get("http://" + ip_addr, verify=False)
            if (
                list(
                    map(
                        lambda x: x in req.content.decode(),
                        [
                            "blog",
                            "Blog",
                            "BLOG",
                            "博客",
                            "小站",
                            "日记",
                            "blogger",
                            "Blogger",
                            "朋友",
                            "小窝",
                            "个人",
                        ],
                    )
                ).count(True)
                != 0
            ):
                content = BeautifulSoup(req.content, "html.parser")
                found.append(
                    {
                        "host": ip_addr,
                        "Server": req.headers.get("Server"),
                        "Title": content.find("title").get_text(),
                    }
                )
                return (True, ip_addr, None)
    except Exception as e:
        return (False, ip_addr, str(e).strip())
    return (False, ip_addr, None)


with ThreadPoolExecutor(max_workers=(os.cpu_count() * 4)) as pool:

    def result_callback(future):
        is_blog, ip_addr, reason = future.result()
        if is_blog:
            print(
                "{ip} is a blog, found[{count}]".format(ip=ip_addr, count=len(found)),
            )
        else:
            print(
                "{ip} is not a blog, found[{count}]:({reason})".format(
                    ip=ip_addr, count=len(found), reason=reason
                )
            )

    try:
        for x, y in itertools.product(range(100, 255), range(255)):
            pool.submit(scanner, "?.?.{x}.{y}".format(x=x, y=y)).add_done_callback(
                result_callback
            )
    except KeyboardInterrupt:
        pprint.pprint(found)

print("*" * 16)
pprint.pprint(found)

with open("./result", "w") as fp:
    fp.write(json.dumps(found, ensure_ascii=False))
    fp.flush()
