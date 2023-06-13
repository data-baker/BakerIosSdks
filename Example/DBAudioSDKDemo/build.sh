#!/bin/bash

# 清理旧的构建文件
rm -rf build
workspaceName="DBAudioSDKDemo"
schemeName="DBAudioSDKDemo"
archiveName="ArchiveName"

# 编译并构建应用
xcodebuild -workspace {worspaceName}.xcworkspace -scheme {schemeName} -configuration Release clean archive -archivePath build/{archiveName}.xcarchive

# 导出 ipa 文件
xcodebuild -exportArchive -archivePath build/{archiveName}.xcarchive -exportPath build/{}.archiveName.ipa -exportOptionsPlist ExportOptions.plist

# 打印构建信息
printf "\n\n=====================================\n"
printf "      Build successful!\n"
printf "      IPA file path: $PWD/build/YourApp.ipa\n"
printf "=====================================\n"
