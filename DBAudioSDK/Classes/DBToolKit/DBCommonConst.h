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

@interface DBCommonConst : NSObject

+ (NSString *)currentTimeString;

+ (NSString *)currentDateString;
@end

NS_ASSUME_NONNULL_END
