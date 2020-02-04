# Protocol Buffer + ZeroMQ + Python
# Как реализовать механизм структуры данных сериализации Google Protocol Buffer (protobuf) и высокопроизводительную библиотеку асинхронного распределенного обмена сообщениями ZeroMQ на Python.

Translated. 
Original version: https://cinema4dr12.tistory.com/884

Для получения подробной информации о каждом из них, пожалуйста, обратитесь к их соответствующим веб-сайтам:
 - Google Protocol Buffer : https://developers.google.com/protocol-buffers/ 
 - ZeroMQ : http://zeromq.org 
 - Python : http://python.org 
 Среда разработки для этого руководства выглядит следующим образом: 
- OS : Microsoft Windows 7 Professional 64 bit 
- IDE : Microsoft Visual Studio 2015 Community 
- Python : version 2.7.11 
- Protobuf-Python : version 3.0.0 beta 2 (protobuf-python-3.0.0-beta-2)

# Создание решения буфера протокола
Загрузите 
- готовый буфер протокола protoc-3.11.2-win64.zip
https://github.com/google/protobuf/releases
или
- исходный код буфера протокола protobuf-all-3.11.2.zip
 со страницы разработчика Google: https://github.com/google/protobuf/releases

Создать модуль Python из файла .proto Запустите файл protoc.exe из protoc-3.11.2-win64.zip для создания модуля Python. 
Опции команды следующие:
```sh
protoc -I=$SRC_DIR --python_out=$DST_DIR $SRC_DIR/people.proto 
```
$ SRC_DIR - это исходный каталог, 
$ DST_DIR обозначает каталог назначения. 
Если это текущий путь, введите «.» 
Например, если proto.exe и people.proto существуют в текущем пути, запустите командную строку в текущем пути и введите: 
```sh
protoc -I=. --python_out=. ./people.proto 
```
Если он работает нормально, файл people_pb2.py создается по указанному пути.

# Установить модуль Python ZeroMQ 
Модуль ZeroMQ для Python - это pyzmq. 
Установите через pip, менеджер пакетов Python:
```sh
pip install pyzmq 
```
Или посетите следующий веб-сайт, чтобы загрузить и установить его самостоятельно: https://pypi.python.org/pypi/pyzmq 
Для справки я скачал и установил «pyzmq-15.3.0 + fix-cp27-cp27m-win_amd64.whl (md5)» непосредственно в 64-битной среде Windows. 
```sh
pip install {PYTHON_ZEROMQ_PATH}/pyzmq-15.3.0+fix-cp27-cp27m-win_amd64.whl (md5)
```
Рекомендуется загрузить и установить соответствующую версию для вашей среды сборки.

#Установите Python Protobuf Module 
Модуль protobuf Python также можно легко установить с помощью pip:
```sh
pip install protobuf 
```
Если нет, загрузите и установите модуль непосредственно по следующей ссылке: https://pypi.python.org/pypi/protobuf Для справки, на момент написания этой статьи последняя версия модуля protobuf Python была 3.0.0. Доступно для загрузки через https://pypi.python.org/pypi/protobuf/3.0.0. Чтобы установить загруженный файл, введите в командной строке следующее: 
```sh
pip install {DOWNLOAD_PATH}/protobuf-3.0.0.tar.gz 
```

#Написание кода Python 

Код Python, который вам нужно написать, состоит из двух частей: один для издателя и один для подписчика. Вы можете узнать больше о модели издателя-подписчика ZeroMQ здесь. Издатель - отправитель сообщения, подписчик - получатель сообщения. Начните с написания кода издателя. 
CODE: people-pub-server.py 
```sh
#! /usr/bin/env python
import zmq
import random
import time
import people_pb2
 
####################################
# Open Port
####################################
port = 8080
 
####################################
# Socket Binding
####################################
context = zmq.Context()
socket = context.socket(zmq.PUB)
socket.bind("tcp://*:%s" % port)
 
####################################
# Get Instance from Protobuf
####################################
people = people_pb2.People()
 
####################################
# Publish Values
####################################
while True:
    people.person.name = "gchoi"
    people.person.email = "cinema4dr12@gmail.com"
    people.person.id = random.randrange(0,100)
 
    socket.send_string("%s" % (people.SerializeToString()))
    print("Name: %s , Email: %s , ID: %d" % (people.person.name, people.person.email, people.person.id))
    time.sleep(1)
```
Обратите внимание, что опция zmq установлена как Publisher (zmq.PUB), когда сокет связан в строке 17, а сообщение о людях передается в виде строки в строке 33.

Теперь напишите код подписчика следующим образом: 
CODE: people-sub-client.py 
```sh
#! /usr/bin/env python
import sys
import zmq
import people_pb2
 
####################################
# Open Port
####################################
port = "8080"
if len(sys.argv) > 1:
    port =  sys.argv[1]
    int(port)
 
####################################
# Socket to talk to server
####################################
context = zmq.Context()
socket = context.socket(zmq.SUB)
print ("Collecting updates from server...")
socket.connect ("tcp://localhost:%s" % port)
 
####################################
# Subscribe to temperature
####################################
topicfilter = ""
socket.setsockopt(zmq.SUBSCRIBE, topicfilter)
 
####################################
# Instance for People
####################################
people = people_pb2.People()
 
####################################
# Process
####################################
while True:
    string = socket.recv()
    people.ParseFromString(string)
    print("%s" % people.person)
```
В подписчике для опции zmq установлено значение Subscriber (zmq.SUB) при привязке к сокету, как показано в строке 18. В строке 37 мы получаем сообщение от Pubslicher, а в линейном 38 мы конвертируем сообщение в строку. 
Результат выполнения python people-pub-server.py Когда вы запускаете Publisher, он генерирует сообщение Person каждую секунду. 
В частности, идентификаторы были сгенерированы случайными числами Затем запустите подписчик, чтобы увидеть результат:
```sh
python people-sub-client.py 
```

Применительно к quik-lua-rpc шаги:
Создается protobuf class из proto файла
```sh
protoc -I=. --python_out=. ./CreateDataSource.proto 
```
В клиенте client_protobuf_python для quik-lua-rpc импортируем созданный класс
```sh
import sys
sys.path.insert(0,'C:\\Users\\путь до директории с созданным CreateDataSource_pb2')
или
sys.path.append('C:\\Users\\путь до директории с созданным CreateDataSource_pb2')
import zmq
import CreateDataSource_pb2

ctx = zmq.Context.instance()
client = ctx.socket(zmq.REQ)
client.connect('tcp://127.0.0.1:5560')

message = CreateDataSource_pb2.Request()
message.class_code = 'QJSIM'
message.sec_code = 'SBER'
message.interval = CreateDataSource_pb2.INTERVAL_M1

request = RPC_pb2.Request()
request.type = RPC_pb2.CREATE_DATA_SOURCE
request.args = message.SerializeToString()
print("Request ", request)
print(request.SerializeToString())
```
