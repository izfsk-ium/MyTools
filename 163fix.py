#!/bin/python3

'''
Fix exif info of 163 downloads 
'''

import requests
import eyed3
import random

from sys import argv
from bs4 import BeautifulSoup
from json import loads
from eyed3.id3.frames import ImageFrame


class Song:
    def __init__(self, path: str) -> None:
        self.audio_file = eyed3.load(path)
        self.music_url = (
            "https://music.163.com/song?id="
            + self.audio_file.tag.comments[0].text.split("/")[-1]
        )
        self.fetch_data()

    def fetch_data(self):
        user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0",
            "Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/98.0",
            "Mozilla/5.0 (X11; Linux x86_64; rv:95.0) Gecko/20100101 Firefox/95.0",
        ]
        response = requests.get(
            self.music_url, headers={"User-Agent": random.choice(user_agents)}
        )
        parsed = BeautifulSoup(response.content, features="lxml")

        img_addr = loads(parsed.select_one("script").text)["images"][0]

        artist = parsed.find("meta", property="og:music:artist")["content"].strip()
        album = parsed.find("meta", property="og:music:album")["content"].strip()

        self.audio_file.tag.artist = artist
        self.audio_file.tag.album = album
        self.audio_file.tag.images.set(
            ImageFrame.FRONT_COVER,
            requests.get(
                img_addr, headers={"User-Agent": random.choice(user_agents)}
            ).content,
            "image/jpeg",
        )

        # album artist
        album_html = BeautifulSoup(
            requests.get(
                parsed.find("meta", property="music:album")["content"],
                headers={"User-Agent": random.choice(user_agents)},
            ).content,
            features="lxml",
        )

        album_artist = album_html.find("p").find("span").text
        self.audio_file.tag.album_artist = album_artist
        print(
            "Artist:" + artist + ", Album:" + album + " ,Album Artist:" + album_artist
        )

        # artist picture if exists
        # artist_page = BeautifulSoup(
        #     requests.get(
        #         parsed.find("meta", property="music:musician").attrs["content"],
        #         headers={"User-Agent": random.choice(user_agents)},
        #     ).content,
        #     features="lxml",
        # )

        # self.audio_file.tag.images.set(
        #     ImageFrame.ARTIST,
        #     requests.get(
        #         artist_page.find("meta", property="og:image").attrs["content"],
        #         headers={"User-Agent": random.choice(user_agents)},
        #     ).content,
        #     "image/jpeg",
        # )

        self.audio_file.tag.save()


def main():
    Song(argv[1])


main()
