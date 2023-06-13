//
//  DBAuthentication.m
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/21.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBAuthentication.h"
#import "DBNetworkHelper.h"

// TODO: 鉴权地址
#ifndef DBRelease
#define DBRelease 1
#endif

#if DBRelease
#define baseURL @"https://openapi.data-baker.com"
#else
#define baseURL @"http://10.10.50.23:9904"
#endif

#define getTokenURL [NSString stringWithFormat:@"%@/oauth/2.0/token",baseURL]


//static  NSString *const getTokenURL = @"https://openapi.data-baker.com/oauth/2.0/token";


@implementation DBAuthentication

+ (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret  block:(DBAuthenticationBlock)block{
    
    NSAssert(block != nil, @"必须设置block");
    if ([clientId isEqualToString:@""] || clientId == nil) {
        NSError * error = [NSError errorWithDomain:@"tokenError" code:80001 userInfo:@{@"info":@"clientId不能为空"}];
        block(nil,error);
        return;
    }
    
    if ([clientSecret isEqualToString:@""] || clientSecret == nil) {
        NSError * error = [NSError errorWithDomain:@"tokenError" code:80001 userInfo:@{@"info":@"clientSecret不能为空"}];
        block(nil,error);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"client_id"] = clientId;
    parameters[@"client_secret"] = clientSecret;
    parameters[@"grant_type"] = @"client_credentials";
    
    [DBNetworkHelper getWithUrlString:getTokenURL parameters:parameters success:^(NSDictionary * _Nonnull data) {
        NSString *accessToken = data[@"access_token"];
        if (!accessToken) {
            static NSInteger rectryCount = 2;
            if (rectryCount >0) {
                [self setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nonnull token, NSError * _Nonnull error) {
                }];
                rectryCount--;
            }else {
                NSError * error = [NSError errorWithDomain:@"tokenError" code:80001 userInfo:@{@"info":@"token获取失败"}];
                block(nil,error);
            }
        }else {
            block(accessToken,nil);
        }
        
    } failure:^(NSError * _Nonnull error) {
        block(nil,error);
    }];
    
}



@end
