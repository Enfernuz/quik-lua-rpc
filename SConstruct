"""
Ссылка на загрузку Quik: https://arqatech.com/ru/support/files/

ZMQ рекомендует для Linux: sudo sysctl -w net.inet.tcp.sendspace=1300000
"""

import os
import SCons
from SCons.Environment import Environment


# НАСТРОЙКА ОКРУЖЕНИЯ
env_vars = os.environ
env = Environment()
env['STATIC_AND_SHARED_OBJECTS_ARE_THE_SAME'] = 1
env.Replace(PROGSUFFIX='.exe')
env.Replace(SHLIBSUFFIX='.dll')
env.Replace(LIBSUFFIX='.lib')
env.Replace(SHOBJSUFFIX='.obj')
env.Replace(OBJSUFFIX='.obj')
env.Replace(CC=os.environ['CC'])
env.Replace(CFLAGS=os.environ['CFLAGS'])

# QUIK-LUA-RPC
qlr_path = env_vars['QUIK_LUA_RPC_PREFIX']
qlr_libs = ['auth',
            'impl',
            'json',
            'qlua',
            'utils',
            'config.json',
            'curve_keypair_generator.lua',
            'main.lua',
            'service.lua',
            ]

# QUIK REDIST
quik_libs_path = env_vars['QUIK_PREFIX']
quik_libs = ['qlua.dll', 'lua53.dll']

# LUA
lua_path = env_vars['LUA_REPO']
lua_obj = env.SharedObject(env.Glob(f'{lua_path}/*.c'))
lua_dll = env.SharedLibrary(f'{lua_path}/lua', lua_obj)

# LUA-PROTOBUF
lua_pb_path = env_vars['LUA_PROTOBUF_REPO']
lua_pb_dll = env.SharedLibrary(f'{lua_pb_path}/libpb.dll',
                               f'{lua_pb_path}/pb.c',
                               CPPPATH=lua_path,
                               LIBPATH=quik_libs_path,
                               LIBS=quik_libs)

# LIBSODIUM
sodium_built = env_vars['SODIUM_PREFIX']

# LIBZMQ
libzmq_built = env_vars['LIBZMQ_PREFIX']
libzmq_dll = f'{libzmq_built}/bin/libzmq.dll'
libzmq_include = f'{libzmq_built}/include'

# LZMQ
lzmq_path = env_vars['LZMQ_REPO']
lzmq_dll = env.SharedLibrary(f'{lzmq_path}/src/liblzmq.dll',
                             [env.Glob(f'{lzmq_path}/src/*.c'),
                              lua_dll, libzmq_dll],
                             CPPPATH=(libzmq_include, lua_path))

# INSTALL
inst_dir = 'built'
inst_path = '{}/{}'.format(os.getcwd(), inst_dir)
mingw_libs = [
    '/usr/lib/gcc/x86_64-w64-mingw32/10-win32/libgcc_s_seh-1.dll',
    '/usr/lib/gcc/x86_64-w64-mingw32/10-win32/libstdc++-6.dll',
]

env.Install(inst_path,
            [libzmq_dll, lua_dll, mingw_libs,
             f'{sodium_built}/bin/libsodium-23.dll'])

env.InstallAs([
    f'{inst_path}/lzmq.dll',
    f'{inst_path}/pb.dll',
], [
    lzmq_dll,
    lua_pb_dll,
])

env.Install(f'{inst_path}/lua', [
    f'{lzmq_path}/src/lua/lzmq',
])

env.Install(f'{inst_path}/lua/quik-lua-rpc',
            [f'{qlr_path}/{i}' for i in qlr_libs])

env.Install(f'{inst_path}/lua/lua-protobuf', [
    env.Glob(f'{lua_pb_path}/*.lua'),
])
