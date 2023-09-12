//
//  DBLogManager.m
//  DBCommon
//
//  Created by 李明辉 on 2020/9/8.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBLogManager.h"
#import "DBCommonConst.h"
#import "DBLogCollectKit.h"

static NSString *const KLogFileName = @"DBRunLog.txt";
static NSString *const KBackUpFileName = @"DBRunLog_BackUp.txt";
static NSUInteger kFileMaxSize = 20; // M


@implementation DBLogManager

+ (void)saveCriticalSDKRunData:(NSString *)string {
    
    // 日志文本的备份
    NSString *filePath = [self getDocPathWithFileName:KLogFileName];
    [self backFileWithLogFilePath:filePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:[@">>>>>>>程序运行日志<<<<<<<<\n" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [handle seekToEndOfFile];
    NSString *dateStr = [DBCommonConst currentDateString];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[userDefaults valueForKey:@"RunLogTime"] isEqualToString:dateStr]) {
        [userDefaults setValue:dateStr forKey:@"RunLogTime"];
        [userDefaults synchronize];
        dateStr = [NSString stringWithFormat:@">>>>>>>>>>>>>>> 日期 %@ >>>>>>>>>>>>>>>",dateStr];
        [handle writeData:[dateStr dataUsingEncoding:NSUTF8StringEncoding]];
        [handle seekToEndOfFile];
    }
    
    string = [NSString stringWithFormat:@"\n%@: %@\n",[DBCommonConst currentTimeString],string];
    [handle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];

}

+ (void)backFileWithLogFilePath:(NSString *)logFilePath {
    BOOL isOverSize = [self checkFileIsOversize:logFilePath];
    if (!isOverSize) {
        return;
    }
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *backUpFilePath = [self getDocPathWithFileName:KBackUpFileName];
    if (![fileManager fileExistsAtPath:backUpFilePath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:backUpFilePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        if (!success) {
            LogerInfo(@"Failed to create backup directory: %@", error);
        }
    }
    
    // 先删除旧的备份文件（可选）
    NSError *deleteError = nil;
    BOOL deleteSuccess = [fileManager removeItemAtPath:backUpFilePath error:&deleteError];
    if (!deleteSuccess && deleteError) {
        LogerInfo(@"Failed to delete old backup file: %@", deleteError);
        return;
    }
    LogerInfo(@"delete backUp file:%@",backUpFilePath);
    
    // 将日志文件复制到备份目录
    NSError *copyError = nil;
    BOOL copySuccess = [fileManager copyItemAtPath:logFilePath toPath:backUpFilePath error:&copyError];
    if (!copySuccess && copyError) {
        LogerInfo(@"Failed to backup log file: %@", copyError);
    }
    
    // 删除日志文件
     deleteSuccess = [fileManager removeItemAtPath:logFilePath error:&deleteError];
    if (!deleteSuccess && deleteError) {
        LogerInfo(@"Failed to delete log file: %@", deleteError);
        return;
    }
    
}

+ (NSString *)getDocPathWithFileName:(NSString *)fileName {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (BOOL)checkFileIsOversize:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    // 获取文件属性
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (fileAttributes) {
        // 获取文件大小
        NSNumber *fileSize = fileAttributes[NSFileSize];
        unsigned long long fileSizeInBytes = [fileSize unsignedLongLongValue];
        // 转换为MB
        double fileSizeInMB = (double)fileSizeInBytes / (1024 * 1024);
        // 检查文件大小是否小于20MB
        if (fileSizeInMB <= kFileMaxSize) {
            return NO;
        } else {
            LogerInfo(@"文件超过20MB");
            return YES;
        }
    } else {
        LogerInfo(@"无法获取文件属性: %@", error);
        return NO;
    }
    
}



@end
