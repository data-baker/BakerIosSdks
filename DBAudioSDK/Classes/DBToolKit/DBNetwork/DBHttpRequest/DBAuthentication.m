//
//  DBAuthentication.m
//  DBSocketRocketKit
//
//  Created by 李明辉 on 2020/8/21.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBAuthentication.h"
#import "DBNetworkHelper.h"


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
    
    [DBNetworkHelper getWithUrlString:KGET_TOKENT_URL parameters:parameters success:^(NSDictionary * _Nonnull data) {
        NSString *accessToken = data[@"access_token"];
        if (!accessToken) {
            NSError * error = [NSError errorWithDomain:@"tokenError" code:80001 userInfo:@{@"info":@"token获取失败"}];
            block(nil,error);
        }else {
            block(accessToken,nil);
        }
        
    } failure:^(NSError * _Nonnull error) {
        block(nil,error);
    }];
    
}



@end
