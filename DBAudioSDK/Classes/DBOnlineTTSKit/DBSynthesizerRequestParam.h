//
//  DBSynthesizerRequestParam.h
//  WebSocketDemo
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 newbike. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DBParamAudioType){
    DBParamAudioTypePCM16K=4, // 返回16K采样率的pcm格式
    DBParamAudioTypePCM8K, // 返回8K采样率的pcm格式
    DBParamAudioTypePCM24K  // 返回24K采样率的pcm格式
};

typedef NS_ENUM(NSUInteger, DBTTSRate) {
    DBTTSRate8k = 1,
    DBTTSRate16k,
    DBTTSRate24k
};
@interface DBSynthesizerRequestParam : NSObject

/// 根据接口获取到的token
@property(nonatomic,copy)NSString * token;

/// 设置发音人声音名称
@property(nonatomic,copy)NSString * voice;

/// 设置要转为语音的合成文本
@property(nonatomic,copy)NSString * text;

/// 合成请求文本的语言,中文(zh)，英文(eng)，粤语(cat)，四川话(sch)，天津话(tjh)，台湾话(tai)，韩语(kr)，巴葡语(bra)，日语(jp)；默认：ZH,更多音色参考官网
@property(nonatomic,copy)NSString * language;

/// 设置播放的语速，在0～9之间（支持浮点值），不传时默认为5
@property(nonatomic,copy)NSString * speed;

/// 设置语音的音量，在0～9之间（只支持整型值），不传时默认值为5
@property(nonatomic,copy)NSString * volume;

/// 设置语音的音调，取值0-9，不传时默认为5中语调
@property(nonatomic,copy)NSString * pitch;

/// 设置语音的rate，可不填，不填时默认为2，取值范围1-8,配合AudioType的参数进行控制，当audioType为24K时，rate默认为3
@property(nonatomic,assign)DBTTSRate rate;
///  根据类型指定audioType，目前仅支持8K和16K的采样率，24K为预留的字段
@property(nonatomic,assign)DBParamAudioType audioType;

/*
 "取值范围0~20；不传时默认为不调整频谱；
 值为0代表使用配置文件tts_attention.conf中spec_adjust_d的值；
 1代表不调整频谱；
 1以上的值代表高频能量增加幅度，值越大声音的高频部分增强越多，听起来更亮和尖细"
 */

@property(nonatomic,copy)NSString * spectrum;
/*
 "取值范围0~20；不传时默认为0，仅针对8K音频频谱的调整。

 "
 */
@property(nonatomic,copy)NSString * spectrum_8k;
/*
 "字级别时间戳功能，同interval=”1”一起使用：
 '0':关闭字级别时间戳功能
 '1':开启字级别时间戳功能
 详细使用方法参考语音合成时间戳"
 */
@property(nonatomic,copy)NSString * enable_subtitles;

/*
 "标点符号静音时长
 设置标点符号静音时长：
 '0'：默认值
 '1'：句中标点停顿较短，适合直播、配音解说等场景
 '2'：句中标点停顿较长，适合朗诵、教学等场景
 "
 */
@property(nonatomic,copy)NSString * silence;


@end

NS_ASSUME_NONNULL_END
