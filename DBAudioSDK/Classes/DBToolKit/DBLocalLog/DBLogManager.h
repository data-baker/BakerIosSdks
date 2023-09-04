//
//  DBLogManager.h
//  DBCommon
//
//  Created by 李明辉 on 2020/9/8.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCommonConst.h"


#ifdef DEBUG
#define DBLog(FORMAT, ...) {\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
[dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];\
[dateFormatter setTimeZone:timeZone];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSSZ"];\
NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
[DBLogManager saveCriticalSDKRunData:[NSString stringWithFormat: @"TIME：%s【FILE：%s--LINE：%d】FUNCTION：%s\n%s\n",[str UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,__PRETTY_FUNCTION__,[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]]]; \
fprintf(stderr,"TIME：%s【FILE：%s--LINE：%d】FUNCTION：%s\n%s\n",[str UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,__PRETTY_FUNCTION__,[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);\
}

#else
 # define DBLog(...);
#endif




NS_ASSUME_NONNULL_BEGIN

@interface DBLogManager : NSObject

+ (void)saveCriticalSDKRunData:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
