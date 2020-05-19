from get_answer import nltk_bot, nlp_bot, WA
from django.http import HttpResponse
from json import dumps, load, dump
from django.views.decorators.csrf import csrf_exempt
import pandas as pd
import openpyxl
import ast

PATH = '/home/NLTKbot/NLTK_API/NLTK_API/get_answer/nltk_datasets/'

def NLTK_answer(request, text, id):
    ans = nltk_bot.chat_tfidf(text, id)
    answer = {
        'answer' : ans
    }
    return HttpResponse(dumps(answer))

def NLP_answer(request, text):
    ans = nlp_bot.run(text)
    answer = {
        'answer' : ans
    }
    return HttpResponse(dumps(answer))

def create_Model(request, name):
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
    id = {
        'id' : new_id
    }
    return HttpResponse(dumps(id))

def edit_Model(request, id, context, text_response):
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)

    name = id2dataset[str(id)]

    book = book = openpyxl.load_workbook(PATH + name)
    sheet = book.active
    row = (context, text_response)
    sheet.append(row)
    book.save(PATH + name)

    result = {
        'result' : True
    }
    return HttpResponse(dumps(result))

def update_Models(request):
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)
    return HttpResponse(dumps(id2dataset))

def get_Model(request, id):
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)
    answer = {
        'dataset' : id2dataset[str(id)]
    }
    return HttpResponse(dumps(answer))

@csrf_exempt
def WA_mode(request):

    if request.method == 'POST':
        body = request.body
        body = body.replace(b':true', b':True')
        body = body.replace(b':false', b':False')
        body = body.replace(b':null', b':""')
        dict_str = body.decode("UTF-8")
        mydata = ast.literal_eval(dict_str)
        print(mydata)
        return WA.processing(mydata)












