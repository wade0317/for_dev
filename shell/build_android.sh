#!/bin/bash
CLEAN=$1

BUILD_DIR=~/Desktop/BUILD_$(date +%Y%m%d%H%M%S)
ANDROID_APP_NAME=GetLikes

RELEASE_NAME=""

#==================Dir=============
DIR=$(cd `dirname $0`; pwd)
cd $DIR/../../../
COCOS2DX_PROJ_DIR=`pwd`
ANDROID_PROJECT_ROOT=$COCOS2DX_PROJ_DIR/frameworks/runtime-src/proj.android
cd $DIR/../../../../../
PINCOLLAGE_DIR=`pwd`

COCOS2DX_LIB_DIR=$PINCOLLAGE_DIR/common/quick/v3.3_final/cocos2d-x/cocos/platform/android/java
FACEBOOK_LIB_DIR=$PINCOLLAGE_DIR/thirdparty/facebook/android/facebook-android-sdk-3.22.0/facebook
GOOGLE_LIB_DIR=$PINCOLLAGE_DIR/thirdparty/google/google-play-services_lib
PINSSIBLEIAP_LIB_DIR=$PINCOLLAGE_DIR/common/third_party_sdk/android/PinssibleIap

CODE_DIR=$PINCOLLAGE_DIR/common/android
LIBS_DIR=$PINCOLLAGE_DIR/thirdparty/android



#================================
#	print dir
#================================
function printDir()
{
	echo 
	echo Check Dir:
	echo 
	echo COCOS2DX_PROJ_DIR		=$COCOS2DX_PROJ_DIR
	echo ANDROID_PROJECT_ROOT	=$ANDROID_PROJECT_ROOT
	echo PINCOLLAGE_DIR			=$PINCOLLAGE_DIR
	echo COCOS2DX_LIB_DIR		=$COCOS2DX_LIB_DIR
	echo FACEBOOK_LIB_DIR		=$FACEBOOK_LIB_DIR
	echo PINSSIBLEIAP_LIB_DIR	=$PINSSIBLEIAP_LIB_DIR
	echo 
	echo 
}

#================================
#	svn update
#================================
function svnUpdate()
{
	echo svnUpdate ...
	TM=`pwd`
	cd $PINCOLLAGE_DIR
	svn cleanup
	echo update $COCOS2DX_PROJ_DIR ...
	cd $COCOS2DX_PROJ_DIR
	svn revert -R .
	svn up
	cd $PINCOLLAGE_DIR/common
	svn revert -R .
	svn up
	cd $PINCOLLAGE_DIR/thirdparty
	svn revert -R .
	svn up
	cd $TM
}


#================================
#	backup File
#================================
function backupFile()
{
	if ! [[ "$BACKUPFILE" == "hasBackFiles" ]]; then
		
		if [[ -d $DIR/backup ]]; then
			rm -rdf $DIR/backup
		fi
		if ! [[ -d $DIR/backup ]]; then
			mkdir $DIR/backup
		fi

		cp -rf "$ANDROID_PROJECT_ROOT"/AndroidManifest.xml $DIR/backup
		cp -rf "$ANDROID_PROJECT_ROOT"/src/org $DIR/backup
		cp -rf "$COCOS2DX_PROJ_DIR"/src $DIR/backup

		chmod 777 $DIR/backup/*

		echo backup files ...
		BACKUPFILE=hasBackFiles
	fi
}


#================================
#	reback File
#================================
function rebackFile()
{
	if [[ -d $DIR/backup ]]; then
		
		cp -rf $DIR/backup/AndroidManifest.xml "$ANDROID_PROJECT_ROOT"/
		cp -rf $DIR/backup/org "$ANDROID_PROJECT_ROOT"/src
		cp -rf $DIR/backup/src "$COCOS2DX_PROJ_DIR"
	fi
}

#================================
#	copy Java Code
#================================
function copyCode()
{
	echo copyCode ...	
	cp -rf "$CODE_DIR"/contact "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/dataCenter "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/iap "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/offerwall "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/push "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/rate "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/share "$ANDROID_PROJECT_ROOT"/src/com/pinssible/follow/
	cp -rf "$CODE_DIR"/utils "$ANDROID_PROJECT_ROOT"/src/com/pinssible/
}


#================================
#	copy Java Lib
#================================
function copyLibs()
{
	echo copyLibs ...		
	cp -rf "$LIBS_DIR"/*.jar "$ANDROID_PROJECT_ROOT"/libs
	cp -rf "$LIBS_DIR"/AppsFlyer/*.jar "$ANDROID_PROJECT_ROOT"/libs
	cp -rf "$LIBS_DIR"/umeng/*.jar "$ANDROID_PROJECT_ROOT"/libs
}

#================================
#	clean java build
#================================
function cleanJavaBuild()
{
	echo clean Java build ...
	rm -fr $ANDROID_PROJECT_ROOT/assets/*
	rm -rdf $ANDROID_PROJECT_ROOT/assets
	rm -rdf $ANDROID_PROJECT_ROOT/bin
}

#================================
#	ant update project
#================================
function antUpdateProject()
{
	echo update project $1
	echo path: $2
	PROJECTNAME=$1
	PROJECTPATH=$2
	TM=`pwd`
	cd $PROJECTPATH
	android update project -t android-21 -p . -n $PROJECTNAME --subprojects > /dev/null
	ant clean > /dev/null
	cd $TM
}

#================================
#	updateProject
#================================
function updateProject()
{
	echo updateProject ...
	antUpdateProject FacebookSDK $PINCOLLAGE_DIR/thirdparty/facebook/android/facebook-android-sdk-3.22.0/facebook
	antUpdateProject google-play-services_lib $PINCOLLAGE_DIR/thirdparty/google/google-play-services_lib 
	antUpdateProject PinssibleIap $PINCOLLAGE_DIR/common/third_party_sdk/android/PinssibleIap 
	antUpdateProject libcocos2dx $PINCOLLAGE_DIR/common/quick/v3.3_final/cocos2d-x/cocos/platform/android/java
	antUpdateProject AppActivity $ANDROID_PROJECT_ROOT
}

#================================
#	read config 
#================================
function readConfigValue()
{
	File=$1
	KEY=$2
	VALUE=`sed "/^[ 	]*$KEY[ 	]*=/!d;s/.*=[ 	]*[\"]*//;s/[\"]//" $File`
	echo $VALUE
}

#================================
#	modify package name
#================================
function modifyPackageName()
{
	#replace
	echo modify package name
	echo
	echo
	CONFIG_FILENAME=$1



	#Android 
	ANDROID_OLD_PACKEGE_NAME=`sed '/[ 	]*package=[ 	]*".*"/!d;s/.*package[ 	]*=[ 	]*"//;;s/".*//' $ANDROID_PROJECT_ROOT/AndroidManifest.xml`
	# ANDROID_OLD_PACKEGE_NAME=com.nextmobilegroup.fanscan
	echo Android:
	echo old $ANDROID_OLD_PACKEGE_NAME
	# android package name

	ANDROID_APP_NAME=`readConfigValue $CONFIG_FILENAME ANDROID_APP_NAME`
	if [ "$ANDROID_APP_NAME" != "" ]; then
		echo ANDROID_APP_NAME: $ANDROID_APP_NAME
		sed -i "" "s:\"[ 	]*app_name[ 	]*\">.*<:\"app_name\">$ANDROID_APP_NAME<:g" $ANDROID_PROJECT_ROOT/res/values/strings.xml
	fi

	ANDROID_PACKEAGE_NAME=`readConfigValue $CONFIG_FILENAME ANDROID_PACKEAGE_NAME`
	NAME=`sed '/^[ ]*ANDROID_PACKEAGE_NAME[ ]*=/!d;s/.*=[ ]*"//;s/"//;s/.*com\.//;s/\..*//' $CONFIG_FILENAME`
	RELEASE_NAME=${ANDROID_APP_NAME}_${NAME}
	echo RELEASE_NAME=$RELEASE_NAME

	echo package:$ANDROID_PACKEAGE_NAME
	sed -i "" "s/$ANDROID_OLD_PACKEGE_NAME/$ANDROID_PACKEAGE_NAME/g" `grep "$ANDROID_OLD_PACKEGE_NAME" -rl  $ANDROID_PROJECT_ROOT/src/`
	sed -i "" "s/$ANDROID_OLD_PACKEGE_NAME/$ANDROID_PACKEAGE_NAME/g" $ANDROID_PROJECT_ROOT/AndroidManifest.xml

	ANDROID_VERSIONCODE=`readConfigValue $CONFIG_FILENAME ANDROID_VERSIONCODE`
	echo android:versionCode=$ANDROID_VERSIONCODE
	sed -i "" "s/android:versionCode[ 	]*=[ 	]*\".*\"/android:versionCode=\"$ANDROID_VERSIONCODE\"/g" $ANDROID_PROJECT_ROOT/AndroidManifest.xml

	ANDROID_VERSIONNAME=`readConfigValue $CONFIG_FILENAME ANDROID_VERSIONNAME`
	echo android:versionName=$ANDROID_VERSIONNAME
	sed -i "" "s/android:versionName[ 	]*=[ 	]*\".*\"/android:versionName=\"$ANDROID_VERSIONNAME\"/g" $ANDROID_PROJECT_ROOT/AndroidManifest.xml
	




	#Key store
	KEY_STORE=`readConfigValue $CONFIG_FILENAME KEY_STORE`
	echo KEY_STORE:$KEY_STORE
	sed -i "" "s:^[ 	]*key.store[ 	]*=.*$:key.store=keystore/$KEY_STORE:g" $ANDROID_PROJECT_ROOT/ant.properties
	KEY_STORE_PASSWORDW=`readConfigValue $CONFIG_FILENAME KEY_STORE_PASSWORDW`
	echo KEY_STORE_PASSWORDW:$KEY_STORE_PASSWORDW
	sed -i "" "s:^[ 	]*key.store.password[ 	]*=.*$:key.store.password=$KEY_STORE_PASSWORDW:g" $ANDROID_PROJECT_ROOT/ant.properties
	KEY_ALIAS=`readConfigValue $CONFIG_FILENAME KEY_ALIAS`
	echo KEY_ALIAS=$KEY_ALIAS
	sed -i "" "s:^[ 	]*key.alias[ 	]*=.*$:key.alias=$KEY_ALIAS:g" $ANDROID_PROJECT_ROOT/ant.properties
	KEY_ALIAS_PASSWORDW=`readConfigValue $CONFIG_FILENAME KEY_ALIAS_PASSWORDW`
	echo KEY_ALIAS_PASSWORDW=$KEY_ALIAS_PASSWORDW
	sed -i "" "s:^[ 	]*key.alias.password[ 	]*=.*$:key.alias.password=$KEY_ALIAS_PASSWORDW:g" $ANDROID_PROJECT_ROOT/ant.properties



	# Umeng
	UMENG_KEY=`readConfigValue $CONFIG_FILENAME UMENG_KEY`
	echo Umeng Key = $UMENG_KEY
	sed -i "" "s/\"UMENG_APPKEY\"[ 	]*android:value[ 	]*=[ 	]*\".*\"/\"UMENG_APPKEY\" android:value = \"$UMENG_KEY\"/g" $ANDROID_PROJECT_ROOT/AndroidManifest.xml

	# --Fyber
	OFFERWALL_APPID_ANDROID=`readConfigValue $CONFIG_FILENAME OFFERWALL_APPID_ANDROID`
	echo FyberAPPID = $OFFERWALL_APPID_ANDROID
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_APPID_ANDROID[ 	]*=.*$/local  OFFERWALL_APPID_ANDROID = \"$OFFERWALL_APPID_ANDROID\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/FyberHelper.lua
	
	OFFERWALL_TOKEN_ANDROID=`readConfigValue $CONFIG_FILENAME OFFERWALL_TOKEN_ANDROID`
	echo FyberAPPTOKEN = $OFFERWALL_TOKEN_ANDROID
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_TOKEN_ANDROID[ 	]*=.*$/local  OFFERWALL_TOKEN_ANDROID = \"$OFFERWALL_TOKEN_ANDROID\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/FyberHelper.lua
	
	# --Supersonic
	OFFERWALL_NAME=`readConfigValue $CONFIG_FILENAME OFFERWALL_NAME`
	echo Supersonic OFFERWALL_NAME = $OFFERWALL_NAME
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_NAME[ 	]*=.*$/local  OFFERWALL_NAME = \"$OFFERWALL_NAME\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/SupersonicHelper.lua
	OFFERWALL_APPKEY_ANDROID=`readConfigValue $CONFIG_FILENAME OFFERWALL_APPKEY_ANDROID`
	echo Supersonic OFFERWALL_APPKEY_ANDROID = $OFFERWALL_APPKEY_ANDROID
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_APPKEY_ANDROID[ 	]*=.*$/local  OFFERWALL_APPKEY_ANDROID = \"$OFFERWALL_APPKEY_ANDROID\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/SupersonicHelper.lua

	# --Parse
	PARSE_APP_KEY=`readConfigValue $CONFIG_FILENAME PARSE_APP_KEY`
	echo Parse PARSE_APP_KEY = $PARSE_APP_KEY
	PARSE_CLIENT_KEY=`readConfigValue $CONFIG_FILENAME PARSE_CLIENT_KEY`
	echo Parse PARSE_CLIENT_KEY = $PARSE_CLIENT_KEY
	sed -i "" "s/^[ 	]*Parse.initialize.*;/Parse.initialize(this, \"$PARSE_APP_KEY\", \"$PARSE_CLIENT_KEY\");/g" $ANDROID_PROJECT_ROOT/src/org/cocos2dx/lua/FollowApplication.java
	
	# --appsflyer
	APPSFLYER_KEY=`readConfigValue $CONFIG_FILENAME APPSFLYER_KEY`
	echo APPSFLYER_KEY = $APPSFLYER_KEY
	sed -i "" "s/^[ 	]*AppsFlyerLib.setAppsFlyerKey.*;/AppsFlyerLib.setAppsFlyerKey(\"$APPSFLYER_KEY\");/g" $ANDROID_PROJECT_ROOT/src/com/pinssible/follow/dataCenter/AppsFlyerHelper.java

	
	# --Feedback Email
	SUPPORT_EMAIL_RECEIVER=`readConfigValue $CONFIG_FILENAME SUPPORT_EMAIL_RECEIVER`
	echo Feedback Email: $SUPPORT_EMAIL_RECEIVER
	sed -i "" "s/^[ 	]*local[ 	]*SUPPORT_EMAIL_RECEIVER[ 	]*=.*$/local  SUPPORT_EMAIL_RECEIVER = \"$SUPPORT_EMAIL_RECEIVER\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/feedback/FeedbackHelper.lua


	# config.lua
	echo 
	echo config for lua:

	sed -i "" "s/^[ 	]*DEBUG[ 	]*=.*$/DEBUG = 0/g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/^[ 	]*CONFIG_SCREEN_WIDTH[ 	]*=.*$/CONFIG_SCREEN_WIDTH = 1440/g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/^[ 	]*CONFIG_SCREEN_HEIGHT[ 	]*=.*$/CONFIG_SCREEN_HEIGHT = 2560/g" $COCOS2DX_PROJ_DIR/src/config.lua


	APP_TYPE=`readConfigValue $CONFIG_FILENAME APP_TYPE` 
	echo APP_TYPE = $APP_TYPE
	sed -i "" "s/^[ 	]*APP_TYPE[ 	]*=.*$/APP_TYPE = \"$APP_TYPE\"/g" $COCOS2DX_PROJ_DIR/src/config.lua

	SERVICE_API_HOST=`readConfigValue $CONFIG_FILENAME SERVICE_API_HOST` 
	echo SERVICE_API_HOST = $SERVICE_API_HOST
	SERVICE_API_HOST=`sed "/^[ ]*SERVICE_API_HOST[ 	]*=/!d;s/.*=[ 	]*[\"]*//;s/[\"]//;s/:/!1!2@3@4#5#6$7$8%9%^^/" $CONFIG_FILENAME`
	sed -i "" "s:^[ 	]*SERVICE_API_HOST[ 	]*=.*$:	SERVICE_API_HOST = \"$SERVICE_API_HOST\":g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/!1!2@3@4#5#6$7$8%9%^^/:/g" $COCOS2DX_PROJ_DIR/src/config.lua


	APP_VERSION=`readConfigValue $CONFIG_FILENAME APP_VERSION` 
	echo APP_VERSION = $APP_VERSION
	sed -i "" "s/^[ 	]*APP_VERSION[ 	]*=.*$/APP_VERSION = $APP_VERSION/g" $COCOS2DX_PROJ_DIR/src/config.lua

	APP_NAME=`readConfigValue $CONFIG_FILENAME APP_NAME` 
	echo APP_NAME = $APP_NAME
	sed -i "" "s/^[ 	]*APP_NAME[ 	]*=.*$/APP_NAME = \"$APP_NAME\"/g" $COCOS2DX_PROJ_DIR/src/config.lua

	APP_NAME_PAYPAL=`readConfigValue $CONFIG_FILENAME APP_NAME_PAYPAL` 
	echo APP_NAME_PAYPAL: $APP_NAME_PAYPAL
	sed -i "" "s/^[ 	]*APP_NAME_PAYPAL[ 	]*=.*$/APP_NAME_PAYPAL = \"$APP_NAME_PAYPAL\"/g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/^[ 	]*APP_ID_ANDROID[ 	]*=.*$/APP_ID_ANDROID = \"$ANDROID_PACKEAGE_NAME\"/g" $COCOS2DX_PROJ_DIR/src/config.lua

	GOOGLE_IAP_PUBLIC_KEY=`readConfigValue $CONFIG_FILENAME GOOGLE_IAP_PUBLIC_KEY` 
	echo GOOGLE_IAP_PUBLIC_KEY = $GOOGLE_IAP_PUBLIC_KEY
	sed -i "" "s:^[ 	]*GOOGLE_IAP_PUBLIC_KEY[ 	]*=.*$:GOOGLE_IAP_PUBLIC_KEY = \"${GOOGLE_IAP_PUBLIC_KEY}\":g" $COCOS2DX_PROJ_DIR/src/config.lua
	echo

	#IAP
	sed -i "" "s/$ANDROID_OLD_PACKEGE_NAME/$ANDROID_PACKEAGE_NAME/g" $COCOS2DX_PROJ_DIR/src/pin/utils/IAPUtils.lua
	echo
}

#================================
#	modify package name
#================================
function androidImgPackage()
{
	echo imgpackage ...
	chmod 777 $COCOS2DX_PROJ_DIR/img/imgpackage.sh
	$COCOS2DX_PROJ_DIR/img/imgpackage.sh > /dev/null	
}

#================================
#	modify package name
#================================
function replaceIconRes()
{
	RESCONFIG_FILE=$1
	PROMOTION_PNG=`readConfigValue $RESCONFIG_FILE PROMOTION_PNG`
	if [ -f $PINCOLLAGE_DIR/common/build_res/android/res/promotion_png/$PROMOTION_PNG ]; then
		echo PROMOTION_PNG:$PROMOTION_PNG
		cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/promotion_png/$PROMOTION_PNG "$ANDROID_PROJECT_ROOT"/app_promotion.png
	else
		echo Error! PROMOTION_PNG is null!!!
	fi

	ANDROID_APP_ICON=`readConfigValue $RESCONFIG_FILE ANDROID_APP_ICON`
	echo ANDROID_APP_ICON:$ANDROID_APP_ICON
	if [ "$ANDROID_APP_ICON" != "" ]; then
		if [ -d $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON ]; then
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon.png "$ANDROID_PROJECT_ROOT"/res/drawable/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_hdpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-hdpi/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_ldpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-ldpi/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_mdpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-mdpi/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_xhdpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-xhdpi/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_xxhdpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-xxhdpi/icon.png
			cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/icon/$ANDROID_APP_ICON/icon_xxxhdpi.png "$ANDROID_PROJECT_ROOT"/res/drawable-xxxhdpi/icon.png
		fi
	fi
	
	LOGING_BK=`readConfigValue $RESCONFIG_FILE LOGING_BK`
	if [ -f $PINCOLLAGE_DIR/common/build_res/android/res/login/$LOGING_BK ]; then
		echo LOGING_BK:$LOGING_BK
		cp -rf $PINCOLLAGE_DIR/common/build_res/android/res/login/$LOGING_BK "$COCOS2DX_PROJ_DIR"/res/textures/2560x1440/login/login_bg.png
	else
		echo Error! LOGING_BK is null!!!
	fi

}

#================================
#	build c++ 
#================================
HAS_BUILDNATIVE=""
function buildNative()
{
	if [[ "$HAS_BUILDNATIVE" == "BUILD" ]]; then
		echo "C++ will not be compriled!"
	else
		HAS_BUILDNATIVE=BUILD
		echo "C++ will be compriled!"
		echo clean native ...
		cd $ANDROID_PROJECT_ROOT
		if [[ "$CLEAN" == "noclean" ]]; then
			#statements
			echo noclean
		else
			rm -fr $ANDROID_PROJECT_ROOT/obj/*
			rm -fr $ANDROID_PROJECT_ROOT/libs/armeabi/*.so
		fi
	fi

	echo build native...
	export NDK_DEBUG=0
	$ANDROID_PROJECT_ROOT/build_native_release.sh
}

#================================
#	copyAPK
#================================
function copyAPK()
{
	if ! [[ -d $BUILD_DIR ]]; then
		echo "mkdir $BUILD_DIR"
		mkdir $BUILD_DIR
	fi

	cp -rf "$ANDROID_PROJECT_ROOT"/bin/AppActivity-release.apk "$BUILD_DIR/$RELEASE_NAME".apk
}


#================================
#	package APK
#================================
function packageAPK()
{
	CONFIG_FILE_NAME=$1
	echo build apk $CONFIG_FILE_NAME

	copyCode

	copyLibs

	rebackFile

	cleanJavaBuild

	replaceIconRes $CONFIG_FILE_NAME

	modifyPackageName $CONFIG_FILE_NAME

	updateProject

	buildNative

	cd $ANDROID_PROJECT_ROOT
	ant release

	copyAPK

	cd $ANDROID_PROJECT_ROOT
	ant clean > /dev/null

}


#================================
#	package APK
#================================
function cleanPackageENV()
{
	echo clean package environment ...
	rm -rdf $ANDROID_PROJECT_ROOT/assets
	rm -rdf $DIR/backup
	rm -rdf $ANDROID_PROJECT_ROOT/src/com/*.java
	rm -rdf $ANDROID_PROJECT_ROOT/libs/*.jar
}


#================================
#	package APK
#================================
function packageAndroid()
{
	echo package Android ...
	FILELIST=`ls $DIR/config/*.lua`
	for configFile in $FILELIST
	do
		echo
		echo
		echo "=============================================================="
		echo $configFile
		echo "=============================================================="
		echo
	 	packageAPK $configFile
	done
}


#======================main


printDir

# svnUpdate

clear

backupFile

androidImgPackage

packageAndroid

rebackFile

cleanPackageENV











