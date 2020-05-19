from seq2seq import seq2seq_wrapper
import importlib
importlib.reload(seq2seq_wrapper)
from seq2seq import data_preprocessing
from seq2seq import data_utils_1
from seq2seq import data_utils_2

########## PART 1 - DATA PREPROCESSING ##########

# Загрзука датасета
metadata, idx_q, idx_a = data_preprocessing.load_data(PATH = '/home/NLTKbot/NLTK_API/NLTK_API/seq2seq/')

#Разделение датасета на тренировочный и тестовый
(trainX, trainY), (testX, testY), (validX, validY) = data_utils_1.split_dataset(idx_q, idx_a)

#Инициализация параметров
xseq_len = trainX.shape[-1] #Размер входов
yseq_len = trainY.shape[-1] #Размер выходов
batch_size = 16 #Размер подпоследовательности
vocab_twit = metadata['idx2w'] #Словарь всех твитов
xvocab_size = len(metadata['idx2w']) #Размер словаря
yvocab_size = xvocab_size
emb_dim = 1024
idx2w, w2idx, limit = data_utils_2.get_metadata()

#Получение(предсказание ответа)
def respond(question, session, model):
    encoded_question = data_utils_2.encode(question, w2idx, limit['maxq'])
    answer = model.predict(session, encoded_question)[0]
    return data_utils_2.decode(answer, idx2w)

def run(question):

    ########## PART 2 - BUILDING THE SEQ2SEQ MODEL ##########

    #Сборка модели seq2seq
    model = seq2seq_wrapper.Seq2Seq(xseq_len = xseq_len,
                                    yseq_len = yseq_len,
                                    xvocab_size = xvocab_size,
                                    yvocab_size = yvocab_size,
                                    ckpt_path = '/home/NLTKbot/NLTK_API/NLTK_API/get_answer/weights/',
                                    emb_dim = emb_dim,
                                    num_layers = 3)



    ########## PART 3 - TRAINING THE SEQ2SEQ MODEL ##########

    #Тренировка модели проводилась в seq2seq_wrapper.py

    ########## PART 4 - TESTING THE SEQ2SEQ MODEL ##########

    #Восстановление последней обученной модели
    session = model.restore_last_session()

    #Запрос ответа
    answer = respond(question, session, model)
    return answer

