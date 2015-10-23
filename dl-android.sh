#!/bin/bash

mkdir -p android
cd android

VERT="\\033[32m"
NORMAL="\\033[00m"
ROUGE="\\033[31m"
ROSE="\\033[35m"
BLEU="\\033[34m"
BLANC="\\033[02m"
BLANCLAIR="\\033[08m"
JAUNE="\\033[33m"
CYAN="\\033[36m"

# @brief Log with a specific status
# param[in] $1 Comment to display
# param[in] $2 status to display (can be "OK" "..." "" "ERROR")
log () {
	log_comment=$1;
	log_state=$2;
	if [ "$log_state" == "ERROR" ]; then
		echo -ne $ROUGE
		log_state=" ERROR "
	elif [ "$log_state" == "WARNING" ]; then
		echo -ne $ROSE
		log_state="WARNING"
	elif [ "$log_state" == "INFO" ]; then
		echo -ne $CYAN
	elif [ "$log_state" == "OK" ]; then
		echo -ne $VERT
		log_state="  OK   "
	elif [ "$log_state" == "" ]; then
		echo -ne $BLEU
	elif [ "$log_state" == "..." ]; then
		echo -ne $JAUNE
		log_state="  ...  "
	fi
	echo -ne "==> "
	echo -ne $log_comment
	if [ "$log_state" != "" ]; then
		echo -ne "\r\t\t\t\t\t\t\t\t\t\t\t[$log_state]"
	fi
	echo -ne "\n$NORMAL"
}

# @brief Download a specif file with checking that the MD5 is correct
#        It check also if the file has been corectly download and MD5 check corectly
# @param[in] $1 File to download
# @param[in] $2 http URL of the file
# @param[in] $3 MD5 of the file
# @param[in] $4 file comment
download_file () {
	file_name=$1;
	file_url=$2;
	file_md5=$3;
	comment=$4;
	log "Check ${file_name} not already download" ""
	dl_enable="false"
	if [ ! -f $1 ]; then
		dl_enable="true"
	elif [ ! -f ".tmp_dl_compleate_${file_name}.txt" ]; then
		dl_enable="true"
	fi
	if [ "${dl_enable}" == "true" ]; then
		log "Download ${comment}" ""
		rm -f ".tmp_dl_compleate_${file_name}.txt"
		wget ${file_url}
		log "Check MD5 ${comment}" ""
		echo "${file_md5}  ${file_name}" > tmp_check.txt
		if ! md5sum -c tmp_check.txt ; then
			log "Check MD5 ${comment}" "ERROR"
			md5sum ${file_name}
			cat tmp_check.txt
			rm tmp_check.txt
			rm ${file_name}
			exit -1
		fi
		#file DL with sucess ==> not interumpted ...
		touch ".tmp_dl_compleate_${file_name}.txt"
		rm tmp_check.txt
		log "Check MD5 ${comment}" "OK"
	fi
}


log "Install android NDK" "..."
# NDK: new version, check here: https://developer.android.com/ndk/downloads/index.html
CURRENT_NDK_VERSION=r10e
CURRENT_NDK_MD5="19af543b068bdb7f27787c2bc69aba7f"
if [ ! -d android-ndk-$CURRENT_NDK_VERSION ]; then
	download_file "android-ndk-$CURRENT_NDK_VERSION-linux-x86_64.bin" "http://dl.google.com/android/ndk/android-ndk-$CURRENT_NDK_VERSION-linux-x86_64.bin" $CURRENT_NDK_MD5 "NDK"
	
	log "Start real install..." ""
	chmod a+x android-ndk-$CURRENT_NDK_VERSION-linux-x86_64.bin
	./android-ndk-$CURRENT_NDK_VERSION-linux-x86_64.bin > tmp_log_ndk_install_list_files.txt
	#rm android-ndk-$CURRENT_NDK_VERSION-linux-x86_64.bin
	log "Install android NDK $CURRENT_NDK_VERSION" "OK"
else
	log "Already install android NDK $CURRENT_NDK_VERSION" "OK"
fi

log "Install android SDK" "..."
# SDK: new version, check here: https://developer.android.com/sdk/index.html#Other
CURRENT_SDK_VERSION=r24.4.1
CURRENT_SDK_MD5="978ee9da3dda10fb786709b7c2e924c0"
if [ ! -d android-sdk-linux ]; then
	download_file "android-sdk_$CURRENT_SDK_VERSION-linux.tgz" "http://dl.google.com/android/android-sdk_$CURRENT_SDK_VERSION-linux.tgz" $CURRENT_SDK_MD5 "SDK"
	
	log "Start real install" ""
	tar xzvf android-sdk_$CURRENT_SDK_VERSION-linux.tgz > tmp_log_sdk_install_list_files.txt
	#rm android-sdk_$CURRENT_SDK_VERSION-linux.tgz
	log "Install android SDK $CURRENT_SDK_VERSION" "OK"
fi

log "Install all revision 19 related (android 4.4.2)" "..."
export PATH=`pwd`/android-sdk-linux/tools:$PATH
# android list sdk --extended
expect -c ' set timeout -1;\
spawn android - update sdk --all --no-ui --filter \
platform-tools,build-tools-22.0.1,android-19,sys-img-armeabi-v7a-android-19;\
expect "Do you accept the license" { exp_send "y\r";exp_continue } '

log "Install all revision 19" "OK"

rm -f sdk
rm -f ndk
ln -s android-sdk-linux sdk
ln -s android-ndk-r10e ndk

export PROJECT_NDK=`pwd`/ndk
export PROJECT_SDK=`pwd`/sdk
