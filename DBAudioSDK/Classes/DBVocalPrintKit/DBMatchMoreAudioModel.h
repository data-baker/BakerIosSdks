//
//  DBMatchMoreAudioModel.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 声纹验证1:N的验证
@interface DBMatchMoreAudioModel : NSObject

/// 通过 client_id，client_secret 调用授权服务获得见 获取访问令牌
@property(nonatomic,copy)NSString * accseeToken;

/// pcm
@property(nonatomic,copy)NSString * format;

/// 音频数据（采样率 16K，位深 16 位，时长最佳 10 秒，最小 5 秒，最大 30 秒）
@property(nonatomic,copy)NSData * audioData;

/// 返回匹配列表的数据条数
@property(nonatomic,copy)NSNumber * listNum;

/// 分数阈值设置，大于该数值则返回比对成功，取值 0-100.0
@property(nonatomic,copy)NSNumber * scoreThreshold;

+ (instancetype)mactchMoreAudioModelWithToken:(NSString *)accessToken
                                   audioData:(NSData *)data
                                     listNum:(NSNumber *)listNum
                              scoreThreshold:(NSNumber *)scoreThreshold;
@end

NS_ASSUME_NONNULL_END
