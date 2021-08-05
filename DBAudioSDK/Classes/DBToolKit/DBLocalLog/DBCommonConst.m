//
//  DBCommonConst.m
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/31.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBCommonConst.h"

@implementation DBCommonConst

+ (NSString *)currentTimeString {
    //时间格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

+ (NSString *)currentDateString {
    //时间格式化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

@end
