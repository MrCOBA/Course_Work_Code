EN_WHITELIST = '0123456789abcdefghijklmnopqrstuvwxyz ' # допустимые символы
EN_BLACKLIST = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~\''  # недопустимые символы

FILENAME = 'data/chat.txt'

limit = {
        'maxq' : 20,
        'minq' : 0,
        'maxa' : 20,
        'mina' : 3
        }

UNK = 'unk'
VOCAB_SIZE = 6000

import random
import sys

import nltk
import itertools
from collections import defaultdict

import numpy as np

import pickle


def ddefault():
    return 1

# Чтение строк файла
def read_lines(filename):
    return open(filename).read().split('\n')[:-1]


# Разделение предложений в строках на разные строки
def split_line(line):
    return line.split('.')


# Фильтрация строк, удаление неверных символов
def filter_line(line, whitelist):
    return ''.join([ ch for ch in line if ch in whitelist ])


# Создание словарей:
# -слово : индекс
# -индекс : слово
def index_(tokenized_sentences, vocab_size):
    # Получение вероятностного распределения слов
    freq_dist = nltk.FreqDist(itertools.chain(*tokenized_sentences))
    # Создание словаря размера 'vocab_size' из самых используемых слов
    vocab = freq_dist.most_common(vocab_size)
    # index2word
    index2word = ['_'] + [UNK] + [ x[0] for x in vocab ]
    # word2index
    word2index = dict([(w,i) for i,w in enumerate(index2word)] )
    return index2word, word2index, freq_dist


# Фильтрация слишком длинных и слишком коротких последовательностей
def filter_data(sequences):
    filtered_q, filtered_a = [], []
    raw_data_len = len(sequences)//2

    for i in range(0, len(sequences), 2):
        qlen, alen = len(sequences[i].split(' ')), len(sequences[i+1].split(' '))
        if qlen >= limit['minq'] and qlen <= limit['maxq']:
            if alen >= limit['mina'] and alen <= limit['maxa']:
                filtered_q.append(sequences[i])
                filtered_a.append(sequences[i+1])

    # Вывод оригинальных и отфильтрованных данных
    filt_data_len = len(filtered_q)
    filtered = int((raw_data_len - filt_data_len)*100/raw_data_len)
    print(str(filtered) + '% filtered from original data')

    return filtered_q, filtered_a





# Создание финального словаря
# Преобразование изначального списка в массивы индексов
# Добавление спициальных символов <PAD>
def zero_pad(qtokenized, atokenized, w2idx):
    # количество строк
    data_len = len(qtokenized)

    # numpy массивы, чтобы хранить индексы
    idx_q = np.zeros([data_len, limit['maxq']], dtype=np.int32)
    idx_a = np.zeros([data_len, limit['maxa']], dtype=np.int32)

    for i in range(data_len):
        q_indices = pad_seq(qtokenized[i], w2idx, limit['maxq'])
        a_indices = pad_seq(atokenized[i], w2idx, limit['maxa'])

        idx_q[i] = np.array(q_indices)
        idx_a[i] = np.array(a_indices)

    return idx_q, idx_a



# Замена слов на индексы в последовательности
def pad_seq(seq, lookup, maxlen):
    indices = []
    for word in seq:
        if word in lookup:
            indices.append(lookup[word])
        else:
            indices.append(lookup[UNK])
    return indices + [0]*(maxlen - len(seq))


def process_data():

    print('\n>> Read lines from file')
    lines = read_lines(filename=FILENAME)

    # Приведение строки к нижнему регистру
    lines = [ line.lower() for line in lines ]

    print('\n:: Sample from read(p) lines')
    print(lines[121:125])

    # Фильтрация ненужных символов
    print('\n>> Filter lines')
    lines = [ filter_line(line, EN_WHITELIST) for line in lines ]
    print(lines[121:125])

    # Фильтрация и удаление слишком длинных и слишком коротких последовательностей
    print('\n>> 2nd layer of filtering')
    qlines, alines = filter_data(lines)
    print('\nq : {0} ; a : {1}'.format(qlines[60], alines[60]))
    print('\nq : {0} ; a : {1}'.format(qlines[61], alines[61]))


    # Преобразование строк в слова
    print('\n>> Segment lines into words')
    qtokenized = [ wordlist.split(' ') for wordlist in qlines ]
    atokenized = [ wordlist.split(' ') for wordlist in alines ]
    print('\n:: Sample from segmented list of words')
    print('\nq : {0} ; a : {1}'.format(qtokenized[60], atokenized[60]))
    print('\nq : {0} ; a : {1}'.format(qtokenized[61], atokenized[61]))


    # Индексация слов
    print('\n >> Index words')
    idx2w, w2idx, freq_dist = index_( qtokenized + atokenized, vocab_size=VOCAB_SIZE)

    print('\n >> Zero Padding')
    idx_q, idx_a = zero_pad(qtokenized, atokenized, w2idx)

    print('\n >> Save numpy arrays to disk')
    # Сохранения массивов
    np.save('idx_q.npy', idx_q)
    np.save('idx_a.npy', idx_a)

    # Сохранение необходимых словарей
    metadata = {
            'w2idx' : w2idx,
            'idx2w' : idx2w,
            'limit' : limit,
            'freq_dist' : freq_dist
                }

    # Запись словарей на диск
    with open('metadata.pkl', 'wb') as f:
        pickle.dump(metadata, f)

def load_data(PATH=''):
    # Чтение словарей
    with open(PATH + 'metadata.pkl', 'rb') as f:
        metadata = pickle.load(f)
    # Чтение numpy массивов
    idx_q = np.load(PATH + 'idx_q.npy')
    idx_a = np.load(PATH + 'idx_a.npy')
    return metadata, idx_q, idx_a


if __name__ == '__main__':
    process_data()