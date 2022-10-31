//
//  DBVocalPrintClient.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import <Foundation/Foundation.h>
#import "DBRegisterAudioModel.h"
#import "DBMatchOneAudioModel.h"
#import "DBMatchMoreAudioModel.h"
#import "DBVPResponseModel.h"


NS_ASSUME_NONNULL_BEGIN

/// ret= yes 时，msg 返回token的信息， ret = no 时，msg 返回相应的错误信息
typedef void (^DBAuthenticationHandler)(BOOL ret, NSString * _Nullable msg);
typedef void (^DBResponseHandler)(DBVPResponseModel * _Nullable resModel);
typedef void (^DBRegisterResHandler)(DBRegisterVPResponseModel * _Nullable resModel);
typedef void (^DBMatchOneResHandler)(DBMatchOneVPResponseModel * _Nullable resModel);
typedef void (^DBMatchMoreResHandler)(DBMatchMoreVPResponseModel * _Nullable resModel);
typedef void (^DBQueryResHandler)(DBVPStatusResponnseModel * _Nullable resModel);

/// 声纹服务的Client
@interface DBVocalPrintClient : NSObject

@property(nonatomic,assign)BOOL isLog;

+ (instancetype)shareInstance;

///  设置声纹Id的信息和回调函数, ret = 0 表示成功 ret != 0 表示失败；
///
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret handler:(DBAuthenticationHandler)handler;

/// 创建声纹库的Id    J
- (void)createVPIDWithAccessToken:(NSString *)accessToken        callBackHandler:(DBResponseHandler)handler;

/// 注册声纹服务
/// @param audioModel 音频的信息
/// @param handler 回调注册的结果
- (void)registerVPWithAuidoModel:(DBRegisterAudioModel *)audioModel callBackHandler:(DBRegisterResHandler)handler;



/// 声纹验证1:1
/// @param audioModel 声纹验证的audioModel
/// @param handler  处理回调的数据
- (void)matchOneVPWithAudioModel:(DBMatchOneAudioModel *)audioModel
              callBackHandler:(DBMatchOneResHandler)handler;

/// 声纹验证1:N
/// @param audioModel 声纹验证的audioModel
/// @param handler  处理回调的数据
- (void)matchMoreVPWithAudioModel:(DBMatchMoreAudioModel *)audioModel
              callBackHandler:(DBMatchMoreResHandler)handler;

/// 查询声纹的状态
/// @param accessToken 通过 client_id，client_secret 调用授权服务获得见 获取访问令牌
/// @param registerId 特征库 id
/// @param handler 回调结果
- (void)matchVPStatusWithAccessToken:(NSString *)accessToken
                          registerId:(NSString *)registerId
                     callBackHandler:(DBQueryResHandler)handler;



/// 删除声纹
/// @param accessToken 通过 client_id，client_secret 调用授权服务获得见 获取访问令牌
/// @param registerId 特征库 id
/// @param handler  回调处理结果
- (void)deleteVPWithAccessToken:(NSString *)accessToken
                          registerId:(NSString *)registerId
                     callBackHandler:(DBResponseHandler)handler;


+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
