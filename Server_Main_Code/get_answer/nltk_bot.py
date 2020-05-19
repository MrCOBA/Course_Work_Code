import pandas as pd
import nltk
import re
from nltk.stem import wordnet
from sklearn.feature_extraction.text import TfidfVectorizer
from nltk import pos_tag
from sklearn.metrics import pairwise_distances
from json import load

PATH = '/home/NLTKbot/NLTK_API/NLTK_API/get_answer/nltk_datasets/'

def text_normalization(text):
    # Приведение текста к нижнему регистру
    text = str(text).lower()
    # Удаление ненужных символов
    spl_char_text = re.sub(r'[^ a-z]', '', text)
    # Создание токенов слов
    tokens = nltk.word_tokenize(spl_char_text)
    # Инициализация лемматизации
    lema = wordnet.WordNetLemmatizer()
    # Определение частей речи
    tags_list = pos_tag(tokens, None)
    lema_words = []
    for token, pos_token in tags_list:
        #Глагол
        if pos_token.startswith('V'):
            pos_val = 'v'
        #Прилагательное
        elif pos_token.startswith('J'):
            pos_val = 'a'
        #Наречие
        elif pos_token.startswith('R'):
            pos_val = 'r'
        #Существительное
        else:
            pos_val = 'n'
        lema_token = lema.lemmatize(token, pos_val)
        #Добавление лемматизированного слова в список
        lema_words.append(lema_token)

    return " ".join(lema_words)


def chat_tfidf(question, id):
    id2dataset = {}
    with open(PATH + 'id2dataset.json', "r") as read_file:
        id2dataset = load(read_file)
    name = id2dataset[str(id)]
    df = pd.read_excel(PATH + name)
    df.ffill(0, True)

    #Чтение обученных вопросов
    df['lemmatized_text'] = df['Context'].apply(text_normalization)
    #Инициализация tf-idf модели
    tfidf = TfidfVectorizer()
    #Запись данных в массив
    x_tfidf=tfidf.fit_transform(df['lemmatized_text']).toarray()
    # Получение всех уникальных слов запроса
    df_tfidf = pd.DataFrame(x_tfidf, columns=tfidf.get_feature_names())
    df_tfidf.head()
    # Нормализация текста
    lemma=text_normalization(question)
    # Применение tf-idf модели
    tf=tfidf.transform([lemma]).toarray()
    # Применение алгоритма косинусоидальной сходимости
    cos=1-pairwise_distances(df_tfidf,tf,metric='cosine')
    # Получение индекса ответа
    index_value=cos.argmax()
    return df['Text Response'].loc[index_value]