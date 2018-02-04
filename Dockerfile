FROM debian:jessie as builder

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGET=/tmp/build
ARG BRANCH=tokennet

RUN ( \
    sed -i -e 's/deb.debian.org/ftp.kr.debian.org/g' /etc/apt/sources.list; \
    apt-get update --fix-missing && \
    apt-get -y dist-upgrade; \
)

RUN ( \
    apt-get -y install locales; \
    echo en_US.UTF-8 UTF-8 > /etc/locale.gen && locale-gen \
)

WORKDIR /tmp
RUN ( \
    apt-get -y install \
        git \
        build-essential \
        pkg-config \
        autoconf \
        automake \
        libtool \
        bison \
        flex \
        libpq-dev \
        clang++-3.5 \
        gcc-4.9 \
        g++-4.9 \
        cpp-4.9 \
    ; \
)

RUN ( \
    echo ${BRANCH}; \
    git clone https://github.com/owlchain/tokennet-core.git /tmp/tokennet-core; \
    cd /tmp/tokennet-core; \
    git checkout ${BRANCH}; \
)

WORKDIR /tmp/tokennet-core
RUN ( \
    git submodule init; \
    git submodule update; \
)

RUN ( \
    ./autogen.sh; \
    CXX=g++-4.9 ./configure --prefix=${TARGET:-/tmp/build} && \
    make && \
    make check && \
    make install; \
)

RUN cat src/StellarCoreVersion.h | grep STELLAR_CORE_VERSION | sed -e "s/.* \"//g" -e 's/-.*//g' > /version.txt
RUN git rev-parse --short HEAD 2>/dev/null > /commit.txt


FROM debian:jessie-slim

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive

RUN ( \
    sed -i -e 's/deb.debian.org/ftp.kr.debian.org/g' /etc/apt/sources.list; \
    apt-get -y update && \
    apt-get -y dist-upgrade; \
)
RUN apt-get -y install curl locales libpq5 ntp ntpdate

RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

RUN ( \
    apt-get -y autoremove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
)

WORKDIR /

COPY --from=builder /version.txt /version.txt
COPY --from=builder /commit.txt /commit.txt
COPY --from=builder /tmp/build/bin/stellar-core /tokennet-core

ADD ./init /init
RUN chmod 700 /init

ENTRYPOINT ["/init"]

# vim: set ft=dockerfile:
