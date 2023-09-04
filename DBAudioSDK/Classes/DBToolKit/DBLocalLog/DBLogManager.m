//
//  DBLogManager.m
//  DBCommon
//
//  Created by 李明辉 on 2020/9/8.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBLogManager.h"
#import "DBCommonConst.h"

@implementation DBLogManager

+ (void)saveCriticalSDKRunData:(NSString *)string {
    
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"DBRunLog.txt"];
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


@end
