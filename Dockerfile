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
    apt-transport-https
# Download and compile AFLNet
# Uncomment if you want arm support
# ENV CPU_TARGET=arm
ADD --keep-git-dir=true https://github.com/aflnet/aflnet.git /opt/aflnet
COPY qemu_mode/build_qemu_support.sh /opt/aflnet/qemu_mode/
WORKDIR /opt/aflnet

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x ./llvm.sh && \
    ./llvm.sh

RUN make clean all && \
    cd llvm_mode && \
    whereis llvm-config \
    make

FROM scratch AS binaries

COPY --from=fuzzer /opt/aflnet/afl-fuzz aflnet-fuzz
COPY --from=fuzzer /opt/aflnet/afl-gcc afl-gcc

