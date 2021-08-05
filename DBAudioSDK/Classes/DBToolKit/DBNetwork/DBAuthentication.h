//
//  DBAuthentication.h
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/21.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,DBNetworkError) {
    DBNetworkErrorClientId = 1001,
    DBNetworkErrorClientSecret,
};
typedef void (^DBAuthenticationBlock)(NSString * _Nullable token,NSError * _Nullable error);

@interface DBAuthentication : NSObject

+ (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret  block:(DBAuthenticationBlock)block;

@end

NS_ASSUME_NONNULL_END
