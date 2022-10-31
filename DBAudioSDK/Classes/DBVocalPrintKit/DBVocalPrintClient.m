//
//  DBVocalPrintClient.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBVocalPrintClient.h"
#import "DBAuthentication.h"
#import "DBNetworkHelper.h"
#import "DBLogManager.h"
#import "DBRegisterAudioModel.h"


static NSString *vocalPrintSDKVersion = @"1.0.81";

/// 创建声纹验证
static NSString *VPCreateIdURL = @"https://openapi.data-baker.com/vpr/createid";

/// 声纹注册
static NSString *VPRegisterURL = @"https://openapi.data-baker.com/vpr/register";

/// 声纹验证 1:1
static NSString *VPMatchOneURL = @"https://openapi.data-baker.com/vpr/match";

/// 声纹验证1:N
static NSString *VPMatchMoreURL = @"https://openapi.data-baker.com/vpr/search";

/// 查询声纹状态码
static NSString *VPQueryStatusURL = @"https://openapi.data-baker.com/vpr/status";

///  删除声纹
 static NSString *VPDeleteURL = @"https://openapi.data-baker.com/vpr/delete";



@implementation DBVocalPrintClient

+ (instancetype)shareInstance {
    static DBVocalPrintClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[DBVocalPrintClient alloc]init];
    });
    return client;
}



- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret handler:(DBAuthenticationHandler)handler {
    NSAssert(handler, @"请设置DBAuthenticationHandler的回调");
    [DBAuthentication setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (error == nil) {
            handler(YES,token);
        }else {
            handler(NO,error.description);
        }
    }];
    
}

- (void)createVPIDWithAccessToken:(NSString *)accessToken callBackHandler:(DBResponseHandler)handler {
    NSAssert(handler, @"请设置DBResponseHandler");
    
    [DBNetworkHelper postWithUrlString:VPCreateIdURL parameters:@{@"access_token":accessToken} success:^(NSDictionary * _Nonnull data) {
        DBVPResponseModel *model = [[DBVPResponseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBVPResponseModel *model = [DBVPResponseModel responseModelWithError:error];
        handler(model);
    }];
    
}

- (void)registerVPWithAuidoModel:(DBRegisterAudioModel *)audioModel callBackHandler:(DBRegisterResHandler)handler {
    
    NSAssert(handler, @"请设置DBRegisterResHandler");

    NSString *audioString = [self base64StringWithData:audioModel.audioData];
    NSDictionary *dict = @{@"access_token":audioModel.accessToken,
                           @"format":audioModel.format,
                           @"audio":audioString,
                           @"registerId":audioModel.registerId,
                           @"name":audioModel.name,
                           @"scoreThreshold":audioModel.scoreThreshold
    };
    
    [DBNetworkHelper postWithUrlString:VPRegisterURL parameters:dict success:^(NSDictionary * _Nonnull data) {
        DBRegisterVPResponseModel *model = [[DBRegisterVPResponseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBRegisterVPResponseModel *model = [DBRegisterVPResponseModel responseModelWithError:error];
        handler(model);
    }];
}

- (void)matchOneVPWithAudioModel:(DBMatchOneAudioModel *)audioModel callBackHandler:(DBMatchOneResHandler)handler {
    NSAssert(handler, @"请设置DBMatchOneResHandler");

    NSString *audioString = [self base64StringWithData:audioModel.audioData];
    
    NSDictionary *dict = @{@"access_token":audioModel.accseeToken,
                           @"format":audioModel.format,
                           @"audio":audioString,
                           @"matchId":audioModel.matchId,
                           @"scoreThreshold":audioModel.scoreThreshold
    };
    
    [DBNetworkHelper postWithUrlString:VPMatchOneURL parameters:dict success:^(NSDictionary * _Nonnull data) {
        DBMatchOneVPResponseModel *model = [[DBMatchOneVPResponseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBMatchOneVPResponseModel *model = [DBMatchOneVPResponseModel responseModelWithError:error];
        handler(model);
    }];
}

- (void)matchMoreVPWithAudioModel:(DBMatchMoreAudioModel *)audioModel callBackHandler:(DBMatchMoreResHandler)handler {
    
    NSAssert(handler, @"请设置DBMatchMoreResHandler");

    NSString *audioString = [self base64StringWithData:audioModel.audioData];
    
    NSDictionary *dict = @{@"access_token":audioModel.accseeToken,
                           @"format":audioModel.format,
                           @"audio":audioString,
                           @"scoreThreshold":audioModel.scoreThreshold,
                           @"listNum":audioModel.listNum
    };
    
    [DBNetworkHelper postWithUrlString:VPMatchMoreURL parameters:dict success:^(NSDictionary * _Nonnull data) {
        DBMatchMoreVPResponseModel *model = [[DBMatchMoreVPResponseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBMatchMoreVPResponseModel *model = [DBMatchMoreVPResponseModel responseModelWithError:error];
        handler(model);
    }];
}

- (void)matchVPStatusWithAccessToken:(NSString *)accessToken registerId:(NSString *)registerId callBackHandler:(DBQueryResHandler)handler {
    NSAssert(handler, @"请设置DBQueryResHandler");

    
    NSDictionary *dict = @{@"access_token":accessToken,
                           @"registerId":registerId
    };
    
    [DBNetworkHelper postWithUrlString:VPQueryStatusURL parameters:dict success:^(NSDictionary * _Nonnull data) {
        DBVPStatusResponnseModel *model = [[DBVPStatusResponnseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBVPStatusResponnseModel *model = [DBVPStatusResponnseModel responseModelWithError:error];
        handler(model);
    }];
}

- (void)deleteVPWithAccessToken:(NSString *)accessToken registerId:(NSString *)registerId callBackHandler:(DBResponseHandler)handler {
    NSAssert(handler, @"请设置DBQueryResHandler");
    NSDictionary *dict = @{@"access_token":accessToken,
                           @"registerId":registerId
    };
    
    [DBNetworkHelper postWithUrlString:VPDeleteURL parameters:dict success:^(NSDictionary * _Nonnull data) {
        DBVPResponseModel *model = [[DBVPResponseModel alloc]init];
        [model setValuesForKeysWithDictionary:data];
        handler(model);
    } failure:^(NSError * _Nonnull error) {
        DBVPResponseModel *model = [DBVPResponseModel responseModelWithError:error];
        handler(model);
    }];
}

- (NSString *)base64StringWithData:(NSData *)data {
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    NSString *audioString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    return audioString;
    
}

- (void)logMessage:(NSString *)message {
    if (self.isLog) {
        NSLog(@"%@", message);
        [DBLogManager saveCriticalSDKRunData:message];
    }
}

+ (NSString *)sdkVersion {
    return vocalPrintSDKVersion;
}

@end
