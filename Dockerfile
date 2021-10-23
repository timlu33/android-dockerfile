FROM ubuntu:20.04

# tzdata since 2018 need set noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT="/home/develiper/Android/sdk/"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"
ENV PATH "$PATH:/home/developer/Android/sdk/"

RUN apt-get update && \
    apt-get install -y curl \
    unzip \
    xz-utils \
    zip \
    git \
    openjdk-11-jdk \
    wget \
    sudo \
    vim

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk && \
    cd Android/sdk && \
    wget -O command-line-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip && \
    unzip command-line-tools.zip && cd cmdline-tools && \
    mkdir temp && mv lib temp/ && mv bin temp/ && \
    yes | ./temp/bin/sdkmanager --licenses && \
    ./temp/bin/sdkmanager "build-tools;31.0.0" "platforms;android-31" "platform-tools" 
