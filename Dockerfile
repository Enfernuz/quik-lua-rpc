FROM debian:stable
MAINTAINER Anton Abrosimov <anton@abrosimov.online>

##
## ===== Настройка окружения =====
##

USER root
ENV CONTAINER docker

## Настройка APT.
ENV DEBIAN_FRONTEND noninteractive
#COPY src/sources.list /etc/apt/sources.list
RUN chmod 0644 /etc/apt/sources.list
RUN chown root:root /etc/apt/sources.list
RUN echo "debconf debconf/frontend select text" | debconf-set-selections && \
    echo "debconf debconf/frontend select noninteractive" | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Настройка локализации.
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales tzdata && \
    sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen ru_RU.UTF-8 && \
    update-locale LANG=ru_RU.UTF-8 && \
    rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG ru_RU.UTF-8

## Установка пакетов для сборки.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bzip2 xz-utils \
        ca-certificates openssl \
        python3-minimal libpython3-stdlib git \
        make pkg-config autoconf automake libtool scons \
        mingw-w64 binutils-mingw-w64 \
        && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Обновление пакетов.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Настройка пользователя.
RUN useradd -u 1000 -d /home/user -m -s /bin/zsh user && \
    usermod -a -G sudo user && \
    mkdir -p /home/user/.config && \
    mkdir -p /home/user/.local/share && \
    chown -R user:user /home/user

## Смена пользователя.
USER user
ENV HOME /home/user
ENV TERM xterm-256color
WORKDIR /home/user

##
## ===== Сборка проекта =====
##

## Общие настройки сборки.
ENV CC x86_64-w64-mingw32-gcc
ENV CFLAGS -DDLL_EXPORT -DFD_SETSIZE=16384 -DZMQ_USE_SELECT -Os -fomit-frame-pointer -m64 -fPIC
ENV CXX x86_64-w64-mingw32-g++
ENV CXXFLAGS -Os -fomit-frame-pointer -m64 -fPIC

## Загрузка исходников lua.
ENV LUA_URL https://github.com/lua/lua.git
ENV LUA_VER 5.3.5
ENV LUA_REPO $HOME/lua

RUN cd $HOME && \
    git clone "$LUA_URL" && \
    cd $LUA_REPO && \
    git checkout v$LUA_VER

## Загрузка исходников lua-protobuf.
ENV LUA_PROTOBUF_URL https://github.com/starwing/lua-protobuf
ENV LUA_PROTOBUF_VER 0.3.2
ENV LUA_PROTOBUF_REPO $HOME/lua-protobuf

RUN cd $HOME && \
    git clone "$LUA_PROTOBUF_URL" && \
    cd $LUA_PROTOBUF_REPO && \
    git checkout $LUA_PROTOBUF_VER

## Загрузка исходников lzmq.
ENV LZMQ_URL https://github.com/zeromq/lzmq
ENV LZMQ_BRANCH master
ENV LZMQ_REPO $HOME/lzmq

RUN cd $HOME && \
    git clone "$LZMQ_URL" && \
    cd $LZMQ_REPO && \
    git checkout $LZMQ_BRANCH

## Сборка libsodium.
ENV SODIUM_URL https://github.com/jedisct1/libsodium.git
ENV SODIUM_VER 1.0.16
ENV SODIUM_REPO $HOME/libsodium
ENV SODIUM_PREFIX built-libsodium

RUN cd $HOME && \
    git clone "$SODIUM_URL" && \
    cd $SODIUM_REPO && \
    git checkout $SODIUM_VER && \
    ./autogen.sh && \
    ./configure \
        --enable-shared --host=x86_64-w64-mingw32 \
        --prefix="$HOME/$SODIUM_PREFIX" \
        --exec-prefix="$HOME/$SODIUM_PREFIX" \
        CC=$CC CFLAGS="$CFLAGS" \
        CXX=$CXX CXXFLAGS="$CXXFLAGS" && \
    make clean && \
    make && \
    make install

## Сборка libzmq.
ENV LIBZMQ_URL https://github.com/zeromq/libzmq.git
ENV LIBZMQ_VER 4.2.5
ENV LIBZMQ_REPO $HOME/libzmq
ENV LIBZMQ_PREFIX built-libzmq
ENV sodium_LIBS built-libsodium

RUN cd $HOME && \
    git clone "$LIBZMQ_URL" && \
    cd $LIBZMQ_REPO && \
    git checkout v$LIBZMQ_VER && \
    ./autogen.sh && \
    ./configure \
        --enable-shared --host=x86_64-w64-mingw32 \
        --with-libsodium=1 \
        --prefix="$HOME/$LIBZMQ_PREFIX" \
        --exec-prefix="$HOME/$LIBZMQ_PREFIX" \
        CC=$CC CFLAGS="$CFLAGS" \
        CXX=$CXX CXXFLAGS="$CXXFLAGS" && \
    make clean && \
    make && \
    make install

## Загрузка исходиниктов quik-lua-rpc.
ENV QUIK_LUA_RPC_PREFIX quik_lua_rpc
ENV QUIK_PREFIX $HOME/$QUIK_LUA_RPC_PREFIX/quik_redist
ENV INST $HOME/built

COPY ./ $HOME/$QUIK_LUA_RPC_PREFIX
USER root
RUN chown -R user:user $HOME/$QUIK_LUA_RPC_PREFIX
USER user
RUN cd $HOME && \
    cp $HOME/$QUIK_LUA_RPC_PREFIX/SConstruct $HOME/SConstruct

RUN cd $HOME && \
    python3 /usr/bin/scons


ENV EXPORT_DIR /mnt/built
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["cd $INST && tar -Jcvf $EXPORT_DIR/quik_lua_rpc.tar.xz ./*"]
