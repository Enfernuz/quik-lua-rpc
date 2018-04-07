
Содержание
=================

  * [Изменение файлов .proto](#Изменение-файлов-proto)
    * [Необходимые инструменты](#Необходимые-инструменты)
    * [Компиляция файлов .proto](#Компиляция-файлов-proto)
  * [Юнит-тесты](#Юнит-тесты)
  * [Сборка lzmq](#Сборка-lzmq)
  
Изменение файлов .proto
--------
### Необходимые инструменты
  * <b>Python 2.7.x</b>
    <br/>Взять интерпретатор Python версии `2.7.x` можно отсюда: https://www.python.org.
    
  * <b>protobuf-lua</b>
    <br/>В комплект входит lua-библиотека для сериализации/десериализации и плагин для компилирования .proto-файлов в .lua-файлы.
    <br/>В самом начале использовался https://github.com/urbanairship/protobuf-lua, но в процессе использования его пришлось слегка модифицировать и поправить, поэтому актуальный инструмент нужно брать отсюда: https://github.com/Enfernuz/protobuf-lua.
    
    <br/>Если у вас Windows, то далее нужно проделать некоторые манипуляции:
    1. Файлу `protoc-plugin/protoc-gen-lua` технически является скриптом на Python, поэтому желательно добавить ему расширение `.py`: `protoc-plugin/protoc-gen-lua.py`;
    2. Рядом с файлом `protoc-plugin/protoc-gen-lua.py` создать файл `protoc-gen-lua.bat` следующего содержания:
    ```
    @echo off
    chdir MY_PATH
    python -u protoc-gen-lua.py
    ```
    , где вместо MY_PATH подставить директорию с файлом `protoc-plugin/protoc-gen-lua.py` (например, `D:\projects\protobuf-lua-master\protoc-plugin\`)
    
  * <b>protobuf</b>
    <br/>Скачать и распаковать компилятор `protobuf` отсюда: https://github.com/google/protobuf/releases.
    <br/>Будем считать, что у вас версия для Windows (например, `protoc-3.5.1-win32.zip`).
  
### Компиляция файлов .proto
  Допустим, в директории `D:\my-proto-files` имеется некий файл `facebook.proto` следующего содержания:
  ```
  syntax = "proto3";
  
  message Person {
        
    string name = 1;
    int32 age = 2;
  }
  
  ```
  Подробный мануал по синтаксисам protobuf можно найти здесь: <a href='https://developers.google.com/protocol-buffers/docs/proto3'>proto3</a> и <a href='https://developers.google.com/protocol-buffers/docs/proto2'>proto2</a>.
  
  Чтобы превратить его в соответствующий .lua-файл, нужно сделать следующее:
  1. В командной строке запустить компилятор protobuf (`папка_с_protobuf/bin/protoc.exe`) со следующими параметрами:
  `--plugin=protoc-gen-lua=PATH_TO_BAT_FILE --lua_out=PATH_OUT --proto_path=PATH_TO_DIR_WITH_FILE PATH_TO_PROTO_FILE`,
  где 
  * `PATH_TO_BAT_FILE` -- путь до файла `protoc-gen-lua.bat`;
  * `PATH_OUT` -- директория, в которую надо поместить скомпилированный .lua-файл;
  * `PATH_TO_DIR_WITH_FILE` -- директория, в которой компилятор будет искать импортируемые .proto-схемы. Является необязательным параметром и пригождается в случае импортирования .proto-схем в другие .proto-схемы;
  * `PATH_TO_PROTO_FILE` -- путь до компилируемой .proto-схемы.
  
  Например, полная команда может выглядеть так:
  <br/>`protoc --plugin=protoc-gen-lua="D:\protobuf-lua\protoc-plugin\protoc-gen-lua.bat" --lua_out=./  --proto_path="D:\my-proto-files" D:\my-proto-files\facebook.proto`
  <br/>Компилировать можно как несколько файлов в одной директории, так и несколько файлов в разных директориях:
  <br/>`protoc --plugin=protoc-gen-lua="D:\protobuf-lua\protoc-plugin\protoc-gen-lua.bat" --lua_out=./  --proto_path="D:\my-proto-files" D:\my-proto-files\*.proto D:\my-other-proto-files\other.proto D:\more-proto-files\*.proto`
  <br/>Более подробную инструкцию найдёте в мануале к компилятору `protoc`.
  <br/>На выходе получится файл `facebook_pb.lua`, который можно подключить и использовать в своём скрипте:
  ```lua
  local facebook = require('facebook_pb')
  local person = facebook.Person()
  person.name = "Jenny"
  person.age = 20
  
  local serialized_person = person:SerializeToString()
  local deserialized_person = facebook.Person()
  deserialized_person:ParseFromString(serialized_person)
  ```

Юнит-тесты
--------
TO BE DESCRIBED

Сборка lzmq
--------
TO BE DESCRIBED
