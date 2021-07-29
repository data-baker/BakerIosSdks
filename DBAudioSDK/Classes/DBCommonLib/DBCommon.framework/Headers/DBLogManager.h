//
//  DBLogManager.h
//  DBCommon
//
//  Created by 李明辉 on 2020/9/8.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBLogManager : NSObject
+ (void)saveCriticalSDKRunData:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
