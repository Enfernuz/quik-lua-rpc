# quik-lua-rpc

[![Build Status](https://travis-ci.com/Enfernuz/quik-lua-rpc.svg?branch=master)](https://travis-ci.com/Enfernuz/quik-lua-rpc)
[![Coverage Status](https://coveralls.io/repos/github/Enfernuz/quik-lua-rpc/badge.svg?branch=master)](https://coveralls.io/github/Enfernuz/quik-lua-rpc?branch=master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

RPC-сервис для вызова процедур из QLUA -- Lua-библиотеки торгового терминала QUIK (ARQA Technologies).

Содержание
=================

  * [Зачем?](#Зачем)
  * [Как это работает?](#Как-это-работает)
  * [Как пользоваться?](#Как-пользоваться)
    * [Установка программы](#Установка-программы)
    * [Установка зависимостей](#Установка-зависимостей)
    * [Запуск программы](#Запуск-программы)
  * [Схемы сообщений Protocol Buffers](#Схемы-сообщений-Protocol-Buffers)
  * [Схемы сообщений JSON](#Схемы-сообщений-JSON)
  * [Примеры](#Примеры)
  * [Разработчикам](#Разработчикам)
  * [FAQ](#faq)
  * [English version](#English-version)

Зачем?
--------
Торговый терминал QUIK -- одно из немногих средств для торговли на российском рынке. Он предоставляет API в виде библиотеки QLua, написанной на Lua. Написать торговую программу, работающую с QUIK, на чём либо отличном от Lua до сих пор было не так просто (хотя и предпринимаются попытки вытащить API QLua в другие языки, например, в C# -- [**QUIKSharp**](https://github.com/finsight/QUIKSharp)).

Как это работает?
--------
Данный сервис представляет собой RPC-прокси над API библиотеки QLua. Сервис исполняется в терминале QUIK в виде Lua-скрипта и имеет прямой доступ к библиотеке QLua. Общение сторонних программ с сервисом осуществляется посредством [**ZeroMQ**](http://zeromq.org/) ("сокеты на стероидах"), реализуя паттерн REQ/REP (Request / Response), по протоколу TCP. Запросы на вызов удалённых процедур и ответы с результатами выполнения этих процедур передаются либо в бинарном виде, сериализованные с помощью [**Protocol Buffers**](https://developers.google.com/protocol-buffers/), либо в символьном виде, сериализованные в JSON. 

Помимо вызова удалённых процедур сервис также может рассылать оповещения о событиях терминала QUIK, реализуя паттерн PUB/SUB (Publisher / Subscriber).

Соответственно, выбор языка программирования для взаимодействия с QLua ограничивается лишь наличием на этом языке реализации ZeroMQ, коих довольно большое количество.

Как пользоваться?
--------
### Установка программы

Скопировать репозиторий в `%PATH_TO_QUIK%/lua/`, где `%PATH_TO_QUIK%` -- путь до терминала QUIK. Если папки `lua` там нет, нужно её создать.

### Установка зависимостей

Распаковать архив `redist.zip`, лежащий в корне репозитория, и следовать инструкциям согласно именам папок. 

Если боитесь запускать приложенные .exe-файлы, то можете скачать соответствующие файлы с сайта Microsoft самостоятельно (обратите внимание, что нужны версии для платформы `x86`): https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads.
	
### Запуск программы
В терминале QUIK в меню Lua-скриптов добавить и запустить скрипт `%PATH_TO_SERVICE%/main.lua`, где `%PATH_TO_SERVICE%` -- путь до папки с программой включительно (например, `D:/QUIK/lua/quik-lua-rpc`).

Конфигурации точек подключения находятся в файле `%PATH_TO_SERVICE%/config.json`.

Краткая справка по формату конфигурационного файла на примере:
	
```json5
{
    // Точки подключения. Может быть сколько угодно различных точек подключения со своими настройками.
    "endpoints": [
    {
        // Тип точки подключения: 
        // "RPC" -- для удалённого вызова процедур,
        // "PUB" -- для рассылки событий терминала.
        "type": "RPC", 
	// Тип протокола сериализации/десериализации сообщений:
	// "json" -- JSON
	// "protobuf" -- Protocol Buffers
	"serde_protocol": "json",
        // Признак активности/неактивности точки. Ненужные на данный момент точки можно деактивировать.
        "active": true, 
        // TCP-адрес точки подключения. 
        // На данный момент ZeroMQ не поддерживает ipc-абстракцию под Windows, 
        // поэтому  для транспорта остаётся TCP.
        "address": {
            "host": "127.0.0.1",
            "port": 5560
        },
        // Секция настройки аутентификации для точки подключения.
        "auth": {
            // Механизм аутентификации ZeroMQ: 
            // "NULL" или пустая строка (нет аутентификации), 
            // "PLAIN" (пара логин/пароль без шифрования трафика),
            // "CURVE" (ключевая пара и шифрование трафика).
            "mechanism": "CURVE",
            // Секция настройки PLAIN-аутентификации.
	    // Может отсутствовать при выборе механизма NULL или CURVE.
            "plain": {
                // Список пользователей для точки подключения.
                "users": [
                    {"username": "test_user", "password": "test_password"}
                ]
            },
            // Секция настройки CURVE-аутентификации.
	    // Может отсутствовать при выборе механизма NULL или PLAIN.
            "curve": {
                    // Серверная ключевая пара CURVE 
		    // (сгенерировать новую пару можно с помощью скрипта curve_keypair_generator.lua)
                    "server": {
                        "public": "rq:rM>}U?@Lns47E1%kR.o@n%FcmmsL/@{H8]yf7",
                        "secret": "JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6"
                    }, 
                    // Список публичных CURVE-ключей пользователей
                    "clients": ["Yne@$w-vo<fVvi]a<NY6T1ed:M$fCG*[IaLV{hID"]
            }
        }
    }, 

    {
        "type": "PUB", 
	"serde_protocol": "json",
        "active": true, 
        "address": {
            "host": "127.0.0.1",
            "port": 5561
        },
        "auth": {
            "mechanism": "PLAIN", 
            "plain": {
                    "users": [
                        {"username": "admin", "password": "letmein"}
                    ]
            }
        }
    }]
}
```

Убедитесь, что используемые вами порты открыты.

### Схемы сообщений Protocol Buffers
Схемы сообщений расположены внутри директории `qlua/rpc` в виде файлов **.proto**.

### Схемы сообщений JSON

** В РАЗРАБОТКЕ **

В общих чертах, формат сообщений такой:

**Запрос:**
```json5
{
  "method":"НАЗВАНИЕ_QLUA-ФУНКЦИИ",
  "args": {
    // АРГУМЕНТЫ QLUA-ФУНКЦИИ
  }
}
```

**Ответ:**
```json5
{
  "method": "НАЗВАНИЕ_QLUA-ФУНКЦИИ",
  "result": // РЕЗУЛЬТАТ QLUA-ФУНКЦИИ (число, объект, строка -- в зависимости от вызываемой функции)
}
```

**Ответ в случае ошибки сервиса:**
```json5
{
  "method":"НАЗВАНИЕ_QLUA-ФУНКЦИИ",
  "error": {
    "code": // ЧИСЛОВОЙ КОД ОШИБКИ,
    "message": "ИНФОРМАЦИЯ ОБ ОШИБКЕ"
  }
}
```

**!!!** Все дробные числа передаются как строки (что в аргументах, что в ответе от сервиса).

### API-клиенты

* Java: 
  * к версии сервиса v1.0: https://github.com/Enfernuz/quik-lua-rpc-java-client/releases/tag/v1.0
  * к версии сервиса v2.0: https://github.com/Enfernuz/quik-lua-rpc-java-client
* Python:
  * к версии сервиса v1.0: https://github.com/euvgub/mmvddss

### Разработчикам

Инструкцию для разработчиков для версий v1.x можно найти здесь: https://github.com/Enfernuz/quik-lua-rpc/blob/master/CONTRIBUTING.md

Для версий v2.x документация находится в разработке.

### FAQ

Q: **Используешь Protocol Buffers, но не используешь gRPC. Как так?**

A: Для Lua пока не запилили генерацию стабов gRPC. Сообщите, когда появится.

Q: **А что насчёт Thrift? Там вроде есть поддержка Lua.**

A: Если мне память не изменяет, там в зависимостях библиотеки, для которых исходники только под UNIX (например, `luabpack`).

English version
--------
If you deliberately want to have the English version of this README or just want some answers, feel free to reach me via GitHub or email. I'm planning to do some English translation, but the laziness is unbearable... Go on, kick my ass a little :)

# Protocol Buffer + ZeroMQ + Python
# Как реализовать механизм структуры данных сериализации Google Protocol Buffer (protobuf) и высокопроизводительную библиотеку асинхронного распределенного обмена сообщениями ZeroMQ на Python.

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
Translated. 
Original version: https://cinema4dr12.tistory.com/884

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

