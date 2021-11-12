//
//  DBAudioDataModel.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//DBRegisterAudioModel

@interface DBRegisterAudioModel : NSObject

/// token
@property(nonatomic,copy)NSString * accessToken;

// audio的音频数据，音频数据 base64（采样率 16K，位深 16 位，时长最佳 10 秒，最小 5 秒，最大 30 秒）
@property(nonatomic,copy)NSData * audioData;

/// 调用创建声纹库接口返回的 id
@property(nonatomic,strong)NSString * registerId;

/// 自定义名字
@property(nonatomic,copy)NSString * name;

/// 注册有效分数，不得低于系统默认值,值必须包含小数点，如50.1， 50.2
@property(nonatomic,copy)NSNumber * scoreThreshold;
/// 仅支持pcm 格式的数据
@property(nonatomic,readonly,copy)NSString * format;

+ (instancetype)registerAudioModelWithToken:(NSString *)accessToken
                                  audioData:(NSData *)data
                                 registerId:(NSString *)registerId
                                       name:(NSString *)name
                             scoreThreshold:(NSNumber *)scoreThreshold;

@end



NS_ASSUME_NONNULL_END
