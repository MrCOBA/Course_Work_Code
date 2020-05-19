import json
import requests
from get_answer import nltk_bot, nlp_bot
from django.http import HttpResponse
from json import load, dump
import pandas as pd
import openpyxl

PATH = '/home/NLTKbot/NLTK_API/NLTK_API/get_answer/nltk_datasets/'
URL = 'https://eu12.chat-api.com/instance123300/'
TOKEN = '7193y17mj9toqb8f'
dict_messages = []


def create_Model(name):
    name += ".xlsx"
    df = pd.DataFrame(columns=['Context', 'Text Response'])
    df = df.copy()
    with pd.ExcelWriter(PATH + name) as writer:
        df.to_excel(writer, index=False)
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)
    new_id = len(id2dataset)
    id2dataset[new_id] = name
    with open(PATH + 'id2dataset.json', "w") as write_file:
        dump(id2dataset, write_file)
    return new_id


def edit_Model(id, context, text_response):
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)

    name = id2dataset[str(id)]

    book = book = openpyxl.load_workbook(PATH + name)
    sheet = book.active
    row = (context, text_response)
    sheet.append(row)
    book.save(PATH + name)


def update_Models():
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)
    return id2dataset


def send_requests(method, data):
    url = URL + method + '?token=' + TOKEN
    headers = {'Content-type': 'application/json'}
    print(data)
    post_data = json.dumps(data)
    answer = requests.post(url, post_data, headers=headers)
    print(answer.json())
    return HttpResponse(answer.json())


def send_message(chatID, text):
    data = {"body" : text, "phone" : chatID.replace('@c.us', ''), "chatID" : chatID}
    return send_requests('sendMessage', data)


def get_nltk_answer(chatID, id, question):
    answer = nltk_bot.chat_tfidf(question, id)
    return send_message(chatID, answer)


def get_nlp_answer(chatID, question):
    answer = nlp_bot.run(question)
    return send_message(chatID, answer)


def help(chatID):
    help_info = """There is list of commands:
        1. \\help - list of commands
        2. \\all - list bot models
        3. \\select%<type> - change model to the <type>
        4. \\new%<name> - create new bot with name <name>
        5. \\add%<context>%<response> - add new replic to the bot
        6. \\current - type and name of choosed model"""
    return send_message(chatID, help_info)


def all(chatID):
    all_info = "There is list of bot models:\n"
    all_info += "%s - Smart, NLP bot.\n"
    id2dataset = update_Models()
    for i in range(len(id2dataset)):
        all_info += "%" + str(i) + " - NLTK bot " + id2dataset[str(i)] + "\n"
    return send_message(chatID, all_info)


def select(chatID, type):
    chatID2dataset = {}
    with open(PATH + 'chatID2dataset.json', "r") as read_file:
        chatID2dataset = load(read_file)
    chatID2dataset[chatID] = type
    with open(PATH + 'chatID2dataset.json', "w") as write_file:
        dump(chatID2dataset, write_file)
    msg = "Now your model is %" + type
    return send_message(chatID, msg)


def create(chatID, name):
    id = create_Model(name)
    chatID2dataset = {}
    with open(PATH + 'chatID2dataset.json', "r") as read_file:
        chatID2dataset = load(read_file)
    chatID2dataset[chatID] = str(id)
    with open(PATH + 'chatID2dataset.json', "w") as write_file:
        dump(chatID2dataset, write_file)
    msg = "You have created new model %" + str(id)
    return send_message(chatID, msg)


def add(chatID, context, text_response):
    chatID2dataset = {}
    with open(PATH + 'chatID2dataset.json', "r") as read_file:
        chatID2dataset = load(read_file)
    id = chatID2dataset[chatID]
    edit_Model(id, context, text_response)
    msg = "Your model was edited successfully!"
    return send_message(chatID, msg)


def current(chatID):
    chatID2dataset = {}
    id2dataset = {}
    with open(PATH + 'chatID2dataset.json', "r") as read_file:
        chatID2dataset = load(read_file)
    id = chatID2dataset[chatID]
    msg = ""
    if id != "s":
        with open(PATH + 'id2dataset.json', "r") as read_file:
            id2dataset = load(read_file)
        name = id2dataset[id]
        msg = "Your current model is %" + id + " - " + name
    else:
        msg = "Your current model is %s - smart NLP model"
    return send_message(chatID, msg)


def check_Command(command):
    if command[0] == "\\add":
        return len(command) == 3
    elif command[0] == "\\new":
        return len(command) == 2
    elif command[0] == "\\select":
        if len(command) == 2:
            id2dataset = update_Models()
            if command[1] == "s":
                return True
            else:
                for ch in command[1]:
                    if ch >= '0' and ch <= '9':
                        continue
                    else:
                        return False

                id = int(command[1])
                return id < len(id2dataset) and id >= 0
        else:
            return False


def set_Bot(chatID):
    chatID2dataset = {}
    with open(PATH + 'chatID2dataset.json', "r") as read_file:
        chatID2dataset = load(read_file)
    if chatID in chatID2dataset:
        return chatID2dataset[chatID]
    else:
        chatID2dataset[chatID] = "0"
        with open(PATH + 'chatID2dataset.json', "w") as write_file:
            dump(chatID2dataset, write_file)
        return "0"


def processing(JS):
    dict_messages = JS['messages']
    if dict_messages != []:
        for message in dict_messages:
            text = message["body"]
            if not message["fromMe"]:
                chatID  = message["chatId"]
                type = set_Bot(chatID)
                if text.lower() == "\\help":
                    return help(chatID)
                elif text.lower() == "\\current":
                    return current(chatID)
                elif text.lower() == "\\all":
                    return all(chatID)
                else:
                    command = (text.lower()).split('%')
                    if check_Command(command):
                        if command[0] == "\\add":
                            return add(chatID, command[1], command[2])
                        elif command[0] == "\\new":
                            return create(chatID, command[1])
                        elif command[0] == "\\select":
                            return select(chatID, command[1])
                        else:
                            return send_message(chatID, "Something going wrong!")
                    else:
                        if type == "s":
                            return get_nlp_answer(chatID, text)
                        else:
                            return get_nltk_answer(chatID, int(type), text)





