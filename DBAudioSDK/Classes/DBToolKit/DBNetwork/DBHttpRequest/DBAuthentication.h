//
//  DBAuthentication.h
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/21.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DBRelease
#define DBRelease 0
#endif

#if DBRelease
#define KBASE_URL @"https://openapi.data-baker.com"
#else
//#define KBASE_URL @"http://10.10.50.23:9904"
#define KBASE_URL @"https://openapitest.data-baker.com"
#endif

#define KGET_TOKENT_URL [NSString stringWithFormat:@"%@/oauth/2.0/token",KBASE_URL]


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
