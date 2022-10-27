//
//  DBFASRClient.h
//  Biaobei
//
//  Created by linxi on 2020/9/14.
//  Copyright © 2020 标贝科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

// 设置采样率
typedef NS_ENUM(NSUInteger, DBOneSpeechSampleRate){
    DBOneSpeechSampleRate16K = 16000, // 16k的采样率
    DBOneSpeechSampleRate8K = 8000, // 8K的采样率
};
// 设置音频类型
typedef NS_ENUM(NSUInteger, DBOneSpeechAudioFormat){
    DBOneSpeechAudioFormatPCM,
    DBOneSpeechAudioFormatWAV,
};
// 错误码
typedef NS_ENUM(NSUInteger, DBOneSpeechASRErrorState){
    DBOneSpeechErrorStateCodeClientId    = 13190001, // 缺少ClientId
    DBOneSpeechErrorStateCodeSecret      = 13190002, // 缺少Secret
    DBOneSpeechErrorStateCodeToken       = 13190003, // token获取失败
    DBOneSpeechErrorNotConnectToServer   = 13190004, // socket链接失败
    DBOneSpeechErrorStateNoMicrophone    = 13190005, // 麦克风没有权限
    DBOneSpeechErrorStateMicrophoneErr   = 13190006, // 麦克风启动失败
    DBOneSpeechErrorStateDataLength      = 13190007, // 数据长度错误
    DBOneSpeechErrorStateDataParse       = 13190008, // 服务器返回数据解析失败
};

@protocol DBFASRClientDelegate <NSObject>
/// token获取回调,log为yes为初始化成功,可以开始识别
- (void)initializationResult:(BOOL)log;
/// 已经与后台连接,可以传入音频流
- (void)onReady;
/// 识别结果回调 message为识别内容 sentenceEnd为是否一句话结束(不是识别结束,还可以继续识别)
- (void)identifyTheCallback:(NSString *)message sentenceEnd:(BOOL)sentenceEnd;
/// 错误回调 code:错误码  message:错误信息
- (void)onError:(NSInteger)code message:(NSString *)message;
/// 麦克风获取的音频分贝值回调
- (void)dbValues:(NSInteger)db;

@optional
/// 每句话识别的TraceID，用于追溯识别结果
/// @param traceId 追溯Id
- (void)resultTraceId:(NSString *)traceId;

@end

/// 处理语音识别相关的功能
@interface DBFASRClient : NSObject

@property (nonatomic, weak) id <DBFASRClientDelegate> delegate;
/// 音频采样率，支持16000，8000 默认16000
@property (nonatomic, assign) DBOneSpeechSampleRate sampleRate;
/// 音频编码格式PCM（文件格式PCM或WAV）默认PCM
@property (nonatomic, assign) DBOneSpeechAudioFormat AudioFormat;
/// 是否在短静音处添加标点，默认为YES
@property (nonatomic, assign) BOOL addPct;
/// 模型名称，必须填写公司购买的语言模型，默认为common
@property (nonatomic, strong) NSString * domain;
//配置的热词组的id
@property (nonatomic, strong) NSString * hotwordid;
//Asr个性化模型的id
@property (nonatomic, strong) NSString * diylmid;
/*
 False: 关闭静音检测（默认）
 True：开启静音检测
 */

@property (nonatomic, assign) BOOL  enable_vad;
/*
 当enable_vad为true时有效，表示允许的最大开始静音时长
 单位：毫秒，取值范围[200,60000]，输入超过范围取临近值，该值是一个参考值，具体可能会根据音频不同有少量浮动。
 超出规定范围后，即开始识别后多长时间没有检测到语音，服务端将会发送错误码90002，表示没有检测到语音，结束本次识别。
 */
@property (nonatomic, assign) NSInteger  max_begin_silence;

/*
 当enable_vad为true时有效，表示允许的最大结束静音时长
 单位：毫秒，取值范围[200, 5000]，输入超过范围取临近值，该值是一个参考值，具体可能会根据音频不同有少量浮动。
 超出规定范围后，即在上句话识别后，间隔多长时间没有检测到语音，结束本次识别，间隔后如果还有后续语音则不会被识别。
 */

@property (nonatomic, assign) NSInteger  max_end_silence;


/// 1.打印日志 0:不打印日志(打印日志会在沙盒中保存一份text,方便我们查看,上线前要置为NO);
@property (nonatomic, assign) BOOL log;

+ (instancetype)shareInstance;
/// 获取token
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
/// 开启识别
- (void)startOneSpeechASR;
/// 结束识别,结束识别并且关闭socket与麦克风
- (void)endOneSpeechASR;
/// 私有化部署URL
- (void)setupURL:(NSString *)url;
/// 开启原始数据识别
- (void)startDataRecognize;
/// 接收识别数据
- (void)webSocketPostData:(NSData *)audioData;

// 一句话识别的版本号
+ (NSString *)oneShortASRSDKVersion;

@end

NS_ASSUME_NONNULL_END


