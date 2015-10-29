# android-download-tool
(APACHE-2) script to download android SDK and NDK

This repository is designed to download the Android SDK and NDK on Travis linux interface. it download the last android SDK and request all basic packages

in your .travis.yml

    env: TAG=Android
    install:
      # download NDK
      - if [ "$TAG" == "Android" ]; then
            cd ..;
            git clone --depth=1 https://github.com/HeeroYui/android-download-tool;
            ./android-download-tool/dl-android.sh;
            export ANDROID_NDK_ROOT=`pwd`/android/ndk"
            export ANDROID_SDK_ROOT=`pwd`/android/sdk"
            cd -;
        fi

This will download the last NDK and SDK in the folder: ../andoid/ndk and ../android/sdk

Note: It does not support other platform than Linux. (for now... ask us to have it on MacOs...)


