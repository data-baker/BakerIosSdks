//
//  DBParamsDelegate.h
//  DBVoiceEngraver
//
//  Created by linxi on 2020/7/23.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol DBParamsDelegate <NSObject>

/// 获取header的信息
- (NSDictionary *)paramasDelegateRequestParamas;

/// 打印信息
- (void)logMessage:(NSString * )format, ... NS_FORMAT_FUNCTION(1, 2);

// 字典转化成JSON字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic;

/// 将JSON转化成为字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/// 新建一个PCM的文件
-(NSString *)makeFile;

/// 清理本地的音频文件,YES清理成功，NO清理失败
- (BOOL)clearAudioFile;

// 移除文件
- (BOOL)removeFileWithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
