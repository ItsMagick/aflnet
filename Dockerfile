# syntax=docker/dockerfile-upstream:master-labs
FROM ubuntu:18.04 AS fuzzer

RUN apt-get -y update && \
    apt-get -y install \
    apt-utils \
    build-essential \
    openssl \
    clang \
    graphviz-dev \
    libcap-dev \
    libtool \
    wget \
    automake \
    autoconf \
    bison \
    tar \
    libglib2.0-dev \
    graphviz-dev \
    libcap-dev \
    lsb-release \
    software-properties-common \
    dirmngr \
    apt-transport-https \
    llvm

# Download and compile AFLNet
# Uncomment if you want arm support
# ENV CPU_TARGET=arm
ADD --keep-git-dir=true https://github.com/ItsMagick/aflnet.git /opt/aflnet
COPY qemu_mode/build_qemu_support.sh /opt/aflnet/qemu_mode/
COPY shared /opt/shared
WORKDIR /opt/aflnet

RUN make clean all && \
    cd llvm_mode && \
    make

ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["./afl-fuzz -Q -i in -o out -N tcp://127.0.0.1/1883 -P MQTT -D 10000 -q 3 -s 3 -E -K -R -m 1000 ../shared/mosquitto"]
