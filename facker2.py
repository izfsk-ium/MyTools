import faker

from random import choice, randint, choices
from json import dump
import time

facker = faker.Faker("zh_CN")
counter = 0


def generate_tasklist():
    channelName = "20中文5S作业清单"
    channelID = facker.sha1()

    subjects = [
        {
            "id": facker.md5(),
            "name": "科目-" + facker.country(),
            "color": choice(
                [
                    "dark",
                    "gray",
                    "red",
                    "pink",
                    "grape",
                    "violet",
                    "indigo",
                    "cyan",
                    "primary",
                    "green",
                    "teal",
                    "lime",
                    "yellow",
                    "orange",
                ]
            ),
        }
        for i in range(5)
    ]

    gen_task = lambda _: {
        "id": facker.md5(),
        "channel": channelName,
        "title": facker.company(),
        "ctime": facker.date_time().timestamp() * 1000,
        "otime": 0
        if randint(0, 1) == 1
        else int(time.mktime(facker.date_between("-1y", "+1y").timetuple())) * 1000,
        "subject": choice(subjects),
        "detail": facker.sentence(20),
        "attachments": [
            {
                "id": facker.md5(),
                "size": randint(1000, 655350),
                "type": facker.mime_type(),
                "name": facker.file_name(),
            }
            for i in range(randint(0, 5))
        ],
        "collection": None
        if randint(0, 1) == 0
        else {"id": facker.sha256(), "limit": randint(1000, 655350)},
    }

    tasks = [gen_task(None) for i in range(5)]
    doneTasks = list(set(map(lambda x: x["id"], choices(tasks, k=3))))

    return {channelID: tasks, "self": [gen_task(None)]}, list(doneTasks)


if __name__ == "__main__":
    tasks, doneTasks = generate_tasklist()
    dump(tasks, open("./test/tasklist.json", "w"), ensure_ascii=False)
    print(list(doneTasks))
    dump(doneTasks, open("./test/doneTasks.json", "w"), ensure_ascii=False)
    print("Done.")
