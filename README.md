# quik-lua-rpc
RPC-сервис для вызова процедур из QLUA -- Lua-библиотеки торгового терминала QUIK (ARQA Technologies).
An RPC-service over the qlua library API for the QUIK trading terminal

Что это?
--------


Как пользоваться?
--------
### Установка программы

Скопировать репозиторий в `%PATH_TO_QUIK%/lua/`, где `%PATH_TO_QUIK%` -- путь до терминала QUIK. Если папки `lua` там нет, нужно её создать.

### Установка зависимостей

#### Установка *LuaRocks* (менеджер пакетов для Lua)
1. Где взять
	* Архивы с дистрибутивами: http://luarocks.github.io/luarocks/releases/
	* Инструкцию по установке можно найти здесь: https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Windows
2. Разархивировать, в командной строке Windows (cmd.exe) перейти в разархивированную папку.
3. Установить: `install.bat /NOREG /L /P %PATH_TO_LUAROCKS%`, где %PATH_TO_LUAROCKS% -- путь, куда нужно установить LuaRocks. Например, `D:/Programs/Lua/LuaRocks`.

	Почитав мануал, опции для установки можете настроить по своему вкусу.
	Например, /L значит "установить также дистрибутив Lua в папку с LuaRocks" -- он нам пригодится далее, т.к. не у всех стоит отдельный дистрибутив Lua.

	На самом деле, нам нужна не вся Lua, а её бинарники (.dll) и заголовочные файлы. Если не хотите ставить ту, что идёт с LuaRocks, то минимальный набор файлов можно взять здесь: http://luabinaries.sourceforge.net/download.html (например, `lua-5.3.4_Win32_bin.zip`). Качать нужно 32-битные версии (Win32), т.к. QUIK использует 32-битную Lua.
	
#### Установка *protobuf* (библиотека для сериализации/десериализации)
1. Скачать Lua-биндинг для protobuf отсюда: https://github.com/Enfernuz/protobuf-lua

	Это форк форка форка :smile:, наверное, единственного Lua-биндинга для protobuf. По  мере работы с ним я внёс некоторые изменения в плагин для генерации Lua-кода, поэтому эта версия будет полезна тем, кто пожелает доработать RPC-сервис по своему усмотрению.
2. Папку `protobuf` поместить в `%PATH_TO_QUIK%/lua/`
3. (Опционально) Скомпилировать файл protobuf/pb.c как DLL под свою машину. 
	
	Кому не хочется возиться, можете попробовать использовать уже готовую pb.dll: в папке dependencies/protobuf/ можно найти сборки 	под версии терминала 7.2.2.3 и 7.14.1.7. Думаю, любая из них подойдёт, т.к. линковка pb.dll осуществлялась с qlua.dll, которая вряд ли сильно менялась от версии к версии.
	
	Для компиляции я пользовался MinGW с командной оболочкой в виде MSYS.
	1. В терминале MSYS переместиться в папку /protobuf/, где находится файл pb.c
	2. Чтобы файл скомпилировался под Windows, нужно убрать строчки 23-33:
	```С
	#if defined(_ALLBSD_SOURCE) || defined(__APPLE__)
	#include <machine/endian.h>
	#else
	#include <endian.h>
	#endif
	```
	Эти строчки можно убрать безболезненно, т.к. процессоры архитектуры x86 и amd64 имеют little endianness, так что препроцессор не вставит функции из endian.h, которые используются далее в файле.
	
	3. Получить объектный файл: `gcc -O3 -I%PATH_TO_LUA%/include -с pb.c`, где `%PATH_TO_LUA%` -- путь до дистрибутива Lua. Если ставили Lua в комплекте с LuaRocks, то это будет путь до LuaRocks. Пример: `gcc -O3 -ID:/programs/LuaRocks/include -с pb.c`
	
	4. Получить DLL: `gcc -shared -o pb.dll pb.o -L%libraries_folder% -l%lua_library%`, где `%libraries_folder%` -- папка с .dll-библиотеками Lua, `%lua_library%` -- имя .dll-библиотеки Lua.
	
	Пример:
	* `%libraries_folder%` -- `D:/QUIK`
	* `%lua_library%` -- `qlua`
	* Итого: `gcc -shared -o pb.dll pb.o -LD:/QUIK -lqlua`
	
	Линковать лучше с прокси-библиотекой Lua (qlua.dll), которая поставляется в коробке с QUIK. Не уверен, что если слинковаться с DLL из, например, Lua for Windows, или с той, что поставляется с LuaRocks, то всё будет работать. Я пробовал линковаться также с lua5.1.dll, которая находится в корне QUIK, но при запуске скрипта получал ошибку, связанную с загрузкой библиотек.
	
4. Файл pb.dll положить в `%PATH_TO_QUIK%/Include/protobuf/` , где `%PATH_TO_QUIK%` -- путь до терминала QUIK (например, `D:/QUIK`)
	
	
