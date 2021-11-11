//
//  DBMatchAudioModel.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 声纹验证1:1 调用的model
@interface DBMatchOneAudioModel : NSObject

/// 通过 client_id，client_secret 调用授权服务获得见 获取访问令牌
@property(nonatomic,copy)NSString * accseeToken;

/// pcm
@property(nonatomic,copy)NSString * format;

/// 音频数据 base64（采样率 16K，位深 16 位，时长最佳 10 秒，最小 5 秒，最大 30 秒）
@property(nonatomic,copy)NSData * audioData;

/// 调用创建声纹库接口返回的 id，调用声纹服务1: 1 的接口需要传入
@property(nonatomic,copy)NSString * matchId;

/// 分数阈值设置，大于该数值则返回比对成功，取值 0-100.0
@property(nonatomic,copy)NSString * scoreThreshold;

@end


NS_ASSUME_NONNULL_END
