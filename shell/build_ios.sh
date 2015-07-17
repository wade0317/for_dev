#!/bin/bash
CLEAN=$1

#./svn.sh

BUILD_IOS_DIR=~/Desktop/BUILD_IOS_$(date +%Y%m%d%H%M%S)
IOS_APP_NAME=GetLikes

RELEASE_NAME=$IOS_APP_NAME

IOS_BUILD_TARGET=newgetlikes_iOS
#==================Dir=============
DIR=$(cd `dirname $0`; pwd)
cd $DIR/../../../
COCOS2DX_PROJ_DIR=`pwd`
IOS_PROJECT_ROOT=$COCOS2DX_PROJ_DIR/frameworks/runtime-src/proj.ios_mac
cd $DIR/../../../../../
PINCOLLAGE_DIR=`pwd`

CONFIG_FILES_FOLDER=$PINCOLLAGE_DIR"/common/build_res/iOS/"
echo $CONFIG_FILES_FOLDER
config_file_array=()
declare -i index=0
echo "Input 1~5 to choose which app:"
for file_name in ${CONFIG_FILES_FOLDER}/allconfig/*; do
	temp_file=`basename $file_name`
	config_file_array[$index]=$file_name
	echo $index " - " $temp_file
	index=index+1
done

read TARGET_CONFIG_FILE_INDEX

TARGET_CONFIG_FILE=${config_file_array[${TARGET_CONFIG_FILE_INDEX}]}
if [ -z "${TARGET_CONFIG_FILE}" ]; then
	echo "input error."
	exit
fi
echo "Target config file: " ${TARGET_CONFIG_FILE}

#工程配置文件名称
cd $IOS_PROJECT_ROOT
PROJECT_FILE=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')



#================================
#	print dir
#================================
function printIOSDir()
{
	echo
	echo Check Dir:
	echo
	echo COCOS2DX_PROJ_DIR		=$COCOS2DX_PROJ_DIR
	echo IOS_PROJECT_ROOT		=$IOS_PROJECT_ROOT
	echo QUICK_V3_ROOT			=$QUICK_V3_ROOT
	echo
	echo
}

#================================
#	back ios files dir
#================================
function backupIOSFile()
{
	if ! [[ "$IOSBACKUPFILE" == "iosHasBackFiles" ]]; then

		if [[ -d $DIR/iosbackup ]]; then
			rm -rdf $DIR/iosbackup
		fi
		if ! [[ -d $DIR/iosbackup ]]; then
			mkdir $DIR/iosbackup
		fi

		# cp -rf "$COCOS2DX_PROJ_DIR"/AndroidManifest.xml $DIR/iosbackup
		cp -rf "$COCOS2DX_PROJ_DIR"/src $DIR/iosbackup
		cp -rf $IOS_PROJECT_ROOT/ios/Info.plist $DIR/iosbackup

		chmod 777 $DIR/iosbackup/*
		echo ios backup files ...
		IOSBACKUPFILE=iosHasBackFiles
	fi
}

#================================
function reBackIOSFile()
{
	echo reback files
	if [[ -d $DIR/iosbackup ]]; then

		# cp -rf $DIR/iosbackup/AndroidManifest.xml "$COCOS2DX_PROJ_DIR"/
		cp -rf $DIR/iosbackup/src "$COCOS2DX_PROJ_DIR"
		cp -rf $DIR/iosbackup/Info.plist $IOS_PROJECT_ROOT/ios
	fi
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
#	modify IOS name
#================================
function modifyIOSName()
{
	#replace
	echo modify package name
	echo
	echo
	CONFIG_FILENAME=$1

	#IOS
	IOS_APP_NAME=`readConfigValue $CONFIG_FILENAME IOS_APP_NAME`
	echo IOS_APP_NAME $IOS_APP_NAME

	sed -i "" "/CFBundleDisplayName/{n; s/string.*$/string>$IOS_APP_NAME<\/string>/;}" $IOS_PROJECT_ROOT/ios/Info.plist

	IOS_PACKEAGE_NAME=`readConfigValue $CONFIG_FILENAME IOS_PACKEAGE_NAME`
	echo IOS_PACKEAGE_NAME $IOS_PACKEAGE_NAME
	NAME=`sed '/^[ ]*IOS_PACKEAGE_NAME[ ]*=/!d;s/.*=[ ]*"//;s/"//;s/.*com\.//;s/\..*//' $CONFIG_FILENAME`
	RELEASE_NAME=${IOS_APP_NAME}_${NAME}
	echo RELEASE_NAME: $RELEASE_NAME
	# IOS_OLD_PACKEAGE_NAME=`sed -i "" "/CFBundleIdentifier/{n; d; p;}" $IOS_PROJECT_ROOT/ios/Info.plist`
	# IOS_OLD_PACKEAGE_NAME=`sed "/CFBundleDisplayName/!d" $IOS_PROJECT_ROOT/ios/Info.plist`
	# echo IOS_OLD_PACKEAGE_NAME: $IOS_OLD_PACKEAGE_NAME
	IOS_OLD_PACKEAGE_NAME=com.jellykitgames.getlikes
	echo IOS_OLD_PACKEAGE_NAME: $IOS_OLD_PACKEAGE_NAME
	sed -i "" "s/$IOS_OLD_PACKEAGE_NAME/$IOS_PACKEAGE_NAME/g" $IOS_PROJECT_ROOT/ios/Info.plist


	IOS_APP_VERSION=`readConfigValue $CONFIG_FILENAME IOS_APP_VERSION`
	echo IOS_APP_VERSION: $IOS_APP_VERSION
	sed -i "" "/CFBundleShortVersionString/{n; s/string.*$/string>$IOS_APP_VERSION<\/string>/;}" $IOS_PROJECT_ROOT/ios/Info.plist

	IOS_OLD_URL_SCHEMES=getlikesyafengcandy
	URL_SCHEMES=`readConfigValue $CONFIG_FILENAME URL_SCHEMES`
	echo URL_SCHEMES: $URL_SCHEMES
	sed -i "" "s/$IOS_OLD_URL_SCHEMES/$URL_SCHEMES/g" $IOS_PROJECT_ROOT/ios/Info.plist
	echo $IOS_PROJECT_ROOT/ios/Info.plist

	IOS_APP_BUILD=`readConfigValue $CONFIG_FILENAME IOS_APP_BUILD`
	echo IOS_APP_BUILD: $IOS_APP_BUILD
	sed -i "" "/CFBundleVersion/{n; s/string.*$/string>$IOS_APP_BUILD<\/string>/;}" $IOS_PROJECT_ROOT/ios/Info.plist

	CHANNELID=`readConfigValue $CONFIG_FILENAME CHANNELID`
	echo CHANNELID = $CHANNELID
	sed -i "" "s/^[ 	]*NSString.*channelId[ 	]*=.*$/NSString *const channelId = @\"$CHANNELID\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm

	# Umeng
	UMENG_KEY=`readConfigValue $CONFIG_FILENAME UMENG_KEY`
	echo Umeng Key = $UMENG_KEY
	sed -i "" "s/^[ 	]*NSString.*kUmengAppKey[ 	]*=.*$/NSString *const kUmengAppKey = @\"$UMENG_KEY\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm

	# --Fyber
	OFFERWALL_APPID_IOS=`readConfigValue $CONFIG_FILENAME OFFERWALL_APPID_IOS`
	echo FyberAPPID = $OFFERWALL_APPID_IOS
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_APPID_IOS[ 	]*=.*$/local  OFFERWALL_APPID_IOS = \"$OFFERWALL_APPID_IOS\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/FyberHelper.lua
	OFFERWALL_TOKEN_IOS=`readConfigValue $CONFIG_FILENAME OFFERWALL_TOKEN_IOS`
	echo FyberAPPTOKEN = $OFFERWALL_TOKEN_IOS
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_TOKEN_IOS[ 	]*=.*$/local  OFFERWALL_TOKEN_IOS = \"$OFFERWALL_TOKEN_IOS\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/FyberHelper.lua

	# --Supersonic
	OFFERWALL_NAME=`readConfigValue $CONFIG_FILENAME OFFERWALL_NAME`
	echo Supersonic OFFERWALL_NAME = $OFFERWALL_NAME
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_NAME[ 	]*=.*$/local  OFFERWALL_NAME = \"$OFFERWALL_NAME\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/SupersonicHelper.lua
	OFFERWALL_APPKEY_IOS=`readConfigValue $CONFIG_FILENAME OFFERWALL_APPKEY_IOS`
	echo Supersonic OFFERWALL_APPKEY_IOS = $OFFERWALL_APPKEY_IOS
	sed -i "" "s/^[ 	]*local[ 	]*OFFERWALL_APPKEY_IOS[ 	]*=.*$/local  OFFERWALL_APPKEY_IOS = \"$OFFERWALL_APPKEY_IOS\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/offerwall/SupersonicHelper.lua

	# // --Parse
	PARSE_APP_KEY=`readConfigValue $CONFIG_FILENAME PARSE_APP_KEY`
	echo PARSE_APP_KEY = $PARSE_APP_KEY
	sed -i "" "s/^[ 	]*NSString.*kParseApplicationId[ 	]*=.*$/NSString *const kParseApplicationId = @\"$PARSE_APP_KEY\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm
	PARSE_CLIENT_KEY=`readConfigValue $CONFIG_FILENAME PARSE_CLIENT_KEY`
	echo Umeng Key = $PARSE_CLIENT_KEY
	sed -i "" "s/^[ 	]*NSString.*kParseClientKey[ 	]*=.*$/NSString *const kParseClientKey = @\"$PARSE_CLIENT_KEY\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm

	APPSFLYER_ID=`readConfigValue $CONFIG_FILENAME APPSFLYER_ID`
	echo Umeng Key = $APPSFLYER_ID
	sed -i "" "s/^[ 	]*NSString.*kAppsFlyerID[ 	]*=.*$/NSString *const kAppsFlyerID = @\"$APPSFLYER_ID\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm

	APPSFLYER_KEY=`readConfigValue $CONFIG_FILENAME APPSFLYER_KEY`
	echo Umeng Key = $APPSFLYER_KEY
	sed -i "" "s/^[ 	]*NSString.*kAppsFlyerKey[ 	]*=.*$/NSString *const kAppsFlyerKey = @\"$APPSFLYER_KEY\";/g" $IOS_PROJECT_ROOT/ios/AppController.mm

	# --Feedback Email
	SUPPORT_EMAIL_RECEIVER=`readConfigValue $CONFIG_FILENAME SUPPORT_EMAIL_RECEIVER`
	echo Feedback Email: $SUPPORT_EMAIL_RECEIVER
	sed -i "" "s/^[ 	]*local[ 	]*SUPPORT_EMAIL_RECEIVER[ 	]*=.*$/local  SUPPORT_EMAIL_RECEIVER = \"$SUPPORT_EMAIL_RECEIVER\"/g" $COCOS2DX_PROJ_DIR/src/thirdparty/feedback/FeedbackHelper.lua


	# config.lua
	echo
	echo config for lua:

	sed -i "" "s/^[ 	]*DEBUG[ 	]*=.*$/DEBUG = 0/g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/^[ 	]*CONFIG_SCREEN_WIDTH[ 	]*=.*$/CONFIG_SCREEN_WIDTH = 640/g" $COCOS2DX_PROJ_DIR/src/config.lua
	sed -i "" "s/^[ 	]*CONFIG_SCREEN_HEIGHT[ 	]*=.*$/CONFIG_SCREEN_HEIGHT = 1136/g" $COCOS2DX_PROJ_DIR/src/config.lua

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
	echo APP_NAME_PAYPAL = $APP_NAME_PAYPAL
	sed -i "" "s/^[ 	]*APP_NAME_PAYPAL[ 	]*=.*$/APP_NAME_PAYPAL = \"$APP_NAME_PAYPAL\"/g" $COCOS2DX_PROJ_DIR/src/config.lua

	APP_ID_IOS=`readConfigValue $CONFIG_FILENAME APP_ID_IOS`
	echo APP_ID_IOS = $APP_ID_IOS
	sed -i "" "s/^[ 	]*APP_ID_IOS[ 	]*=.*$/APP_ID_IOS = $APP_ID_IOS/g" $COCOS2DX_PROJ_DIR/src/config.lua


	#IAP
	sed -i "" "s/com.foxcloudloft.newlikes/$IOS_PACKEAGE_NAME/g" $COCOS2DX_PROJ_DIR/src/pin/utils/IAPUtils.lua
	echo
}


#================================
#	modify package name
#================================
function replaceIOSIconRes()
{
	RESCONFIG_FILE=$1
	PROMOTION_PNG=`readConfigValue $RESCONFIG_FILE PROMOTION_PNG`
	if [ -f $PINCOLLAGE_DIR/common/build_res/iOS/res/promotion_png/$PROMOTION_PNG ]; then
		echo PROMOTION_PNG:$PROMOTION_PNG
		cp -rf $PINCOLLAGE_DIR/common/build_res/iOS/res/promotion_png/$PROMOTION_PNG "$IOS_PROJECT_ROOT"/ios/app_promotion.png
	else
		echo Error! PROMOTION_PNG is null!!!
	fi

	IOS_APP_ICON=`readConfigValue $RESCONFIG_FILE IOS_APP_ICON`
	echo IOS_APP_ICON:$IOS_APP_ICON
	if [ "$IOS_APP_ICON" != "" ]; then
		if [ -d $PINCOLLAGE_DIR/common/build_res/iOS/res/icon/$IOS_APP_ICON ]; then
			cp -rf $PINCOLLAGE_DIR/common/build_res/iOS/res/icon/$IOS_APP_ICON/*.png "$IOS_PROJECT_ROOT"/ios
		fi
	fi

	LOGING_BK=`readConfigValue $RESCONFIG_FILE LOGING_BK`
	if [ -d $PINCOLLAGE_DIR/common/build_res/iOS/res/login/$LOGING_BK ]; then
		echo LOGING_BK:$LOGING_BK
		cp -rf $PINCOLLAGE_DIR/common/build_res/iOS/res/login/$LOGING_BK/*.png "$IOS_PROJECT_ROOT"/ios
		cp -rf $PINCOLLAGE_DIR/common/build_res/iOS/res/login/$LOGING_BK/Default-568h@2x.png "$COCOS2DX_PROJ_DIR"/res/textures/1136x640/login/login_bg.png
	else
		echo Error! LOGING_BK is null!!!
	fi

}

#================================
#	modify package name
#================================
function iosImagpack()
{
	echo imgpackage ...
	chmod 777 $COCOS2DX_PROJ_DIR/img/imgpackage.sh
	$COCOS2DX_PROJ_DIR/img/imgpackage.sh > /dev/null
}

#================================
#	zip lua
#================================
function zipLua()
{
	echo zipLua ...
	if [ -f $COCOS2DX_PROJ_DIR/res/game.zip ]; then
		rm -rf $COCOS2DX_PROJ_DIR/res/game.zip
	fi

	$QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i $COCOS2DX_PROJ_DIR/src -o $COCOS2DX_PROJ_DIR/res/game.zip -e xxtea_zip -es XXTEAPIN -ek pingetfollowers

	if [ -d $COCOS2DX_PROJ_DIR/src ]; then
		rm -rdf $COCOS2DX_PROJ_DIR/src/*
	fi

	if [ -d $COCOS2DX_PROJ_DIR/res/textures/2560x1440 ]; then
		rm -rdf $ $COCOS2DX_PROJ_DIR/res/textures/2560x1440
	fi

}

#================================
#	build IOS
#================================
function buildIOS()
{
	echo build ios
	cd $IOS_PROJECT_ROOT
	# /usr/libexec/PlistBuddy -c "set :CHANNELID ${CHANNELID[$i]}" /Users/jc/Desktop/yourproject/woMusic/AppConfig.plist
	mkdir $BUILD_IOS_DIR

	if [[ "$CLEAN" == "noclean" ]]; then
		#statements
		echo noclean
	else
		xcodebuild -project ./$PROJECT_FILE.xcodeproj -target $IOS_BUILD_TARGET clean
	fi


	xcodebuild -project ./$PROJECT_FILE.xcodeproj -target $IOS_BUILD_TARGET DSTROOT="${BUILD_IOS_DIR}" -configuration Release -sdk iphoneos build

	# xcodebuild -project ./$PROJECT_FILE.xcodeproj -target $IOS_BUILD_TARGET -configuration Release -sdk iphoneos DSTROOT="$BUILD_IOS_DIR" build
 	xcrun -sdk iphoneos PackageApplication -v "${IOS_PROJECT_ROOT}/build/Release-iphoneos/newgetlikes_iOS.app" -o "${BUILD_IOS_DIR}/${RELEASE_NAME}.ipa"

 	# xcodebuild -project ./$PROJECT_FILE.xcodeproj -target $IOS_BUILD_TARGET DSTROOT="${BUILD_IOS_DIR}" CODE_SIGN_IDENTITY="iPhone Distribution:Tang YaFeng"

 	# xcrun -sdk iphoneos PackageApplication -v "${IOS_PROJECT_ROOT}/build/Release-iphoneos/newgetlikes_iOS.app" -o "${BUILD_IOS_DIR}/${RELEASE_NAME}.ipa" --sign "iPhone Distribution:Tang YaFeng"

}

#================================
#	package IPA
#================================
function packageIPA()
{
	CONFIG_FILE_NAME=$1
	echo build ipa $CONFIG_FILE_NAME

	backupIOSFile

	reBackIOSFile

	replaceIOSIconRes $CONFIG_FILE_NAME

	# iosImagpack

	modifyIOSName $CONFIG_FILE_NAME

	zipLua

	# buildIOS

}


#================================
#	package IOS
#================================
function packageIOS()
{
	echo package IOS ...
	packageIPA  ${TARGET_CONFIG_FILE}
	#FILELIST=`ls $DIR/config/*.js`
	#for configFile in $FILELIST
	#do
	#	echo
	#	echo
	#	echo "=============================================================="
	#	echo $configFile
	#	echo "=============================================================="
	#	echo
	# 	packageIPA $configFile
	#done
}
#======================main


printIOSDir

iosImagpack

packageIOS

#reBackIOSFile
