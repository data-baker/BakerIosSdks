//
//  DBUncaughtExceptionHandler.h
//  PageController
//
//  Created by linxi on 16/8/10.
//  Copyright © 2016年 biaobei. All rights reserved.

//

#import <Foundation/Foundation.h>

@interface DBUncaughtExceptionHandler : NSObject

/**
 日志文件路径
 */
@property (nonatomic, retain, readonly) NSString *exceptionFilePath;

/**
 创建一个异常捕获类的单例
 */
+ (instancetype)shareInstance;

//void HandleException(NSException *exception);
//void SignalHandler(int signal);
DBUncaughtExceptionHandler* DBInstallUncaughtExceptionHandler(void);
@end
