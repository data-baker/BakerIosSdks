//
//  DBUncaughtExceptionHandler.m
//  PageController
//
//  Created by linxi on 16/8/10.
//  Copyright © 2016年 biaobei. All rights reserved.
//

#import "DBUncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "DBCommonConst.h"

NSString * const DBUncaughtExceptionHandlerSignalExceptionName = @"DBUncaughtExceptionHandlerSignalExceptionName";
NSString * const DBUncaughtExceptionHandlerSignalKey = @"DBUncaughtExceptionHandlerSignalKey";
NSString * const DBUncaughtExceptionHandlerAddressesKey = @"DBUncaughtExceptionHandlerAddressesKey";
volatile int32_t DBUncaughtExceptionCount = 0;
const int32_t DBUncaughtExceptionMaximum = 10;
const NSInteger DBUncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger DBUncaughtExceptionHandlerReportAddressCount = 5;

static NSUncaughtExceptionHandler *_previousHandler;

@interface DBUncaughtExceptionHandler ()

@property (nonatomic, retain) NSString *logFilePath;
@end

@implementation DBUncaughtExceptionHandler
+ (instancetype)shareInstance {
    static DBUncaughtExceptionHandler *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[self alloc]init];
        // 1.获取Documents路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 2.创建文件路径
        NSString *filePath = [docPath stringByAppendingPathComponent:@"DBExceptionLog.txt"];
        single.logFilePath = filePath;
    });
    return single;
}

+ (NSArray *)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = DBUncaughtExceptionHandlerSkipAddressCount; i < DBUncaughtExceptionHandlerSkipAddressCount + DBUncaughtExceptionHandlerReportAddressCount; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_logFilePath]) {
        [fileManager createFileAtPath:_logFilePath contents:[@">>>>>>>程序异常日志<<<<<<<<\n" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    NSString *exceptionMessage = [NSString stringWithFormat:NSLocalizedString(@"\n********** %@ 异常原因如下: **********\n%@\n%@\n========== End ==========\n", nil), [DBCommonConst currentTimeString], [exception reason], [exception callStackSymbols]];
    // 4.创建文件对接对象,文件对象此时针对文件，可读可写
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:_logFilePath];
    [handle seekToEndOfFile];
    [handle writeData:[exceptionMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
    //NSLog(@"%@", filePath);
}
- (void)db_handleException:(NSException *)exception {
    NSArray<NSString *>*callStackSymbols = [exception callStackSymbols];
//    NSLog(@"堆栈%@",callStackSymbols);
    //mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    //匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    for (int index = 0; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
//                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                //filter category and system class
//                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    if ([className hasPrefix:@"DB"]) {
                        [self validateAndSaveCriticalApplicationData:exception];
                    }else {
//                        NSLog(@"当前崩溃不在SDK中");
                    }
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
//                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }
    
//    NSString * message = [NSString stringWithFormat:NSLocalizedString(@"DB异常原因如下:\n%@\n%@", nil), [exception reason], [[exception userInfo] objectForKey:DBUncaughtExceptionHandlerAddressesKey]];
//    NSLog(@"%@",message);

    if (_previousHandler) {
        _previousHandler(exception);
    }
    
    
}

- (NSString *)exceptionFilePath {
    return _logFilePath;
}

@end
void DB_HandleException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&DBUncaughtExceptionCount);
    if (exceptionCount > DBUncaughtExceptionMaximum) {
        return;
    }
//    NSArray *callStack = [DBUncaughtExceptionHandler backtrace];
//    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
//    [userInfo setObject:callStack forKey:DBUncaughtExceptionHandlerAddressesKey];
//    [[DBUncaughtExceptionHandler shareInstance] performSelectorOnMainThread:@selector(db_handleException:) withObject: [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
    [[DBUncaughtExceptionHandler shareInstance] db_handleException:exception];
}
void DBSignalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&DBUncaughtExceptionCount);
    if (exceptionCount > DBUncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:DBUncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [DBUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:DBUncaughtExceptionHandlerAddressesKey];
    [[DBUncaughtExceptionHandler shareInstance] performSelectorOnMainThread:@selector(db_handleException:) withObject: [NSException exceptionWithName:DBUncaughtExceptionHandlerSignalExceptionName reason: [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil), signal] userInfo: [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:DBUncaughtExceptionHandlerSignalKey]] waitUntilDone:YES];
}
DBUncaughtExceptionHandler* DBInstallUncaughtExceptionHandler(void) {
    _previousHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&DB_HandleException);
    signal(SIGABRT, DBSignalHandler);
    signal(SIGILL, DBSignalHandler);
    signal(SIGSEGV, DBSignalHandler);
    signal(SIGFPE, DBSignalHandler);
    signal(SIGBUS, DBSignalHandler);
    signal(SIGPIPE, DBSignalHandler);
    return [DBUncaughtExceptionHandler shareInstance];
}

