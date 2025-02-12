FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    gcc g++ make gcc-multilib g++-multilib \
    openjdk-17-jre python3.10 \
    wget unzip git cmake \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/abc/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
ENV NDK_VERSION=25.1.8937393
ENV NDK_HOME=$ANDROID_HOME/ndk/$NDK_VERSION

WORKDIR $ANDROID_HOME

RUN wget -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip \
    && mkdir cmdline-tools && unzip -d cmdline-tools cmdline-tools.zip && mv cmdline-tools/cmdline-tools cmdline-tools/latest \
    && rm cmdline-tools.zip \
    && yes | sdkmanager --licenses \
    && sdkmanager "ndk;$NDK_VERSION"

WORKDIR /abc

ARG NODE_VERSION=v18.12.1

RUN wget -O node.tar.gz https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.gz \
    && tar -zxf node.tar.gz && mv node-$NODE_VERSION node \
    && cp -r node node-ref \
    && rm node.tar.gz

ARG JAVET_POINT=main

RUN git clone https://github.com/caoccao/Javet.git -b 2.0.2 javet && cd javet && git switch -c abc $JAVET_POINT \
    && cp -r . ../javet-ref

RUN apt-get update && apt-get install -y \
    neovim \
    && rm -rf /var/lib/apt/lists/*

COPY gen-patch-node.sh gen-patch-javet.sh ./

COPY javet.patches node.patches build.sh ./
