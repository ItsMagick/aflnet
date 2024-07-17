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
    libglib2.0-dev

# Download and compile AFLNet
ENV LLVM_CONFIG="llvm-config-6.0"
# Uncomment if you want arm support
# ENV CPU_TARGET=arm
ADD --keep-git-dir=true https://github.com/aflnet/aflnet.git /opt/aflnet
COPY qemu_mode/build_qemu_support.sh /opt/aflnet/qemu_mode/
WORKDIR /opt/aflnet

RUN chmod +x /opt/aflnet/qemu_mode/build_qemu_support.sh

RUN make clean all && \
    cd llvm_mode && \
    make && \
    cd ../qemu_mode && \
    ./build_qemu_support.sh

FROM scratch AS binaries

COPY --from=fuzzer /opt/aflnet/afl-fuzz aflnet-fuzz
COPY --from=fuzzer /opt/aflnet/afl-qemu-trace afl-qemu-trace

