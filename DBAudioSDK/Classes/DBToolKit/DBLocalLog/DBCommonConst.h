//
//  DBCommonConst.h
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/31.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef bb_dispatch_main_async_safe
#define bb_dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

#define KAUDIO_SDK_VERSION @"1.1.0"

static inline BOOL IsEmpty(id thing) {
    return (thing == nil) || [thing isEqual:[NSNull null]] ||
    ([thing isKindOfClass:[NSString class]] && [[(NSString *)thing stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)] && [(NSArray *)thing count] == 0);
}

static inline NSError * throwError(NSString *errorDomain, NSInteger code, NSString *msg) {
    NSError * error = [NSError errorWithDomain:errorDomain code:code userInfo:@{@"msg":msg}];
    return error;
}


@interface DBCommonConst : NSObject

+ (NSString *)currentTimeString;

+ (NSString *)currentDateString;

+ (NSString *)systemVersion;

+ (NSString *)getCurrentDeviceModel;

@end

NS_ASSUME_NONNULL_END
