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
  * [Примеры и гайды](#Примеры-и-гайды)
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
### Версия терминала QUIK
DLL-файлы из `qlua_redist/...` были взяты от QUIK 9.2.3.15. Соответственно, библиотека расчитана на работу с терминалом _примерно_ этой версии и может не(корректно) работать в терминалах QUIK версий, отличных от указанной.

### Установка программы из архива

Распакуйте архив `built/quik_lua_rpc.tar.xz` в каталог установленного терминала Quik (например, `D:/QUIK/`).  
Результаты антивирусной проверки `built/quik_lua_rpc.tar.xz`: [VirusTotal](https://www.virustotal.com/gui/file/ff09a06634f9c57b43c95ba7e88fcf9571c8d1121b089a08f6992744a114a418?nocache=1).

### Сборка и установка из исходников

1. Установите Docker и Docker-compose для вашей операционной системы.
2. Клонируйте этот репозиторий.
3. Хорошая идея - заменить библиотеки в каталоге `quik_redist` на версии из вашего Quik (результаты антивирусной проверки 03.12.2021: [lua53.dll](https://www.virustotal.com/gui/file/febb5cc35dc2b514160cb4dbb81490c346d284a00807f3366dd89d6af0812989/detection), [qlua.dll](https://www.virustotal.com/gui/file/0c3cff03f3a3873f98ca752322462a0869b4569a732055270133fda368480e6e/details)).
4. Откройте консоль в каталоге репозитория.
5. Соберите образ Docker. `docker-compose build --force-rm`
6. Создайте установочный архив. `docker-compose run quik-lua-rpc`
7. Распакуйте архив `built/quik_lua_rpc.tar.xz` в каталог установленного терминала Quik (например, `D:/QUIK/`).

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
  * к версии сервиса v2.0: https://gitlab.com/abrosimov.a.a/qlua
  
### Примеры и гайды

* [Пример работы с ZeroMQ и Protobuf в Python](docs/python_zmq_protobuf.md)

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
