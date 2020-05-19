import numpy as np
from random import sample


#Разделение данных на тренировочные (70%), тестовые (15%) и оценочная (15%)
def split_dataset(x, y, ratio = [0.7, 0.15, 0.15] ):
    # Количество примеров
    data_len = len(x)
    lens = [ int(data_len*item) for item in ratio ]

    trainX, trainY = x[:lens[0]], y[:lens[0]]
    testX, testY = x[lens[0]:lens[0]+lens[1]], y[lens[0]:lens[0]+lens[1]]
    validX, validY = x[-lens[-1]:], y[-lens[-1]:]

    return (trainX,trainY), (testX,testY), (validX,validY)


#Генерация подпоследовательностей (Batches)
def batch_gen(x, y, batch_size):
    while True:
        for i in range(0, len(x), batch_size):
            if (i+1)*batch_size < len(x):
                yield x[i : (i+1)*batch_size ].T, y[i : (i+1)*batch_size ].T


#Генерация подпоследовательностей со случайными наборами элементов
def rand_batch_gen(x, y, batch_size):
    while True:
        sample_idx = sample(list(np.arange(len(x))), batch_size)
        yield x[sample_idx].T, y[sample_idx].T


#Генерация функции декодирования
def decode(sequence, lookup, separator=''):
    return separator.join([ lookup[element] for element in sequence if element ])