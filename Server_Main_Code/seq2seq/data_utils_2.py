EN_WHITELIST = '0123456789abcdefghijklmnopqrstuvwxyz '


import numpy as np
import pickle

# Загрузка словарей с диска
def get_metadata():
    with open('/home/NLTKbot/NLTK_API/NLTK_API/seq2seq/metadata.pkl', 'rb') as f:
        metadata = pickle.load(f)
    return metadata.get('idx2w'), metadata.get('w2idx'), metadata.get('limit')


#Генерация функции декодирования
def decode(sequence, lookup, separator=' '):
    return separator.join([ lookup[element] for element in sequence if element ])



# Функция кодирования
def encode(sentence, lookup, maxlen, whitelist=EN_WHITELIST, separator=''):
    # Приведение к нижнему регистру
    sentence = sentence.lower()
    # Удаление неправильных символов
    sentence = ''.join( [ ch for ch in sentence if ch in whitelist ] )
    # Переведение слов в индексы
    indices_x = [ token for token in sentence.strip().split(' ') ]
    # Сжимание последовательности
    indices_x = indices_x[-maxlen:] if len(indices_x) > maxlen else indices_x
    # Добавление специальных символов
    idx_x = np.array(pad_seq(indices_x, lookup, maxlen))
    return idx_x.reshape([maxlen, 1])


# Замена слов на индексы
def pad_seq(seq, lookup, maxlen):
    indices = []
    for word in seq:
        if word in lookup:
            indices.append(lookup[word])
        else:
            indices.append(lookup['unk'])
    return indices + [0]*(maxlen - len(seq))