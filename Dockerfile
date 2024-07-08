# syntax=docker/dockerfile-upstream:master-labs
FROM ubuntu:18.04 AS aflnet

RUN apt-get -y update && \
    apt-get -y install sudo \
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

ADD --keep-git-dir=true https://github.com/aflnet/aflnet.git /opt/aflnet
COPY qemu_mode/build_qemu_support.sh /opt/aflnet/qemu_mode/
WORKDIR /opt/aflnet

RUN chmod +x /opt/aflnet/qemu_mode/build_qemu_support.sh

RUN make clean all && \
    cd llvm_mode && \
    make && \
    cd ../qemu_mode && \
    ./build_qemu_support.sh

# Set up environment variables for AFLNet
ENV AFLNET="/opt/aflnet"
ENV PATH="${PATH}:${AFLNET}"
ENV AFL_PATH="${AFLNET}"
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
    AFL_SKIP_CPUFREQ=1
