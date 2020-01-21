FROM openjdk:8

ENV ANDROID_HOME /opt/android-sdk-linux

RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O android_tools.zip && \
    unzip android_tools.zip && \
    rm android_tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Accept Android SDK licenses

RUN yes | sdkmanager --licenses

RUN touch /root/.android/repositories.cfg


 # Platform tools
RUN sdkmanager "emulator" "tools" "platform-tools"

# SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.

RUN yes | sdkmanager --update --channel=3
# Please keep all sections in descending order!
RUN yes | sdkmanager \
    "platforms;android-29" \
    "platforms;android-28" \
    "build-tools;29.0.2" \
    "system-images;android-29;google_apis;x86" \
    "system-images;android-28;google_apis;x86" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21"

# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN apt-get update \
 && apt-get -y install gradle \
 && gradle -v

# ------------------------------------------------------
# --- Install additional packages

# Required for Android ARM Emulator
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libqt5widgets5
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/tools/lib64:${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

# -------------------------------------------------------
# Tools to parse apk/aab info in deploy-to-bitrise-io step
ENV APKINFO_TOOLS /opt/apktools
RUN mkdir ${APKINFO_TOOLS}
RUN wget -q https://github.com/google/bundletool/releases/download/0.10.3/bundletool-all-0.10.3.jar -O ${APKINFO_TOOLS}/bundletool.jar
RUN cd /opt \
    && wget -q https://dl.google.com/dl/android/maven2/com/android/tools/build/aapt2/3.5.0-5435860/aapt2-3.5.0-5435860-linux.jar -O aapt2.jar \
    && unzip -q aapt2.jar aapt2 -d ${APKINFO_TOOLS} \
    && rm aapt2.jar

# ------------------------------------------------------
# --- Cleanup and rev num

# Cleaning
RUN apt-get clean
