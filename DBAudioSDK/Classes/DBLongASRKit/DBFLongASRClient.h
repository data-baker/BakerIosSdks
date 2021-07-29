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
typedef NS_ENUM(NSUInteger, DBLongTimeSampleRate){
    DBLongTimeSampleRate16K = 16000, // 16k的采样率
    DBLongTimeSampleRate8K = 8000, // 8K的采样率
};
// 设置音频类型
typedef NS_ENUM(NSUInteger, DBLongTimeAudioFormat){
    DBLongTimeAudioFormatPCM,
    DBLongTimeAudioFormatWAV,
};
// 错误码
typedef NS_ENUM(NSUInteger, DBLongTimeASRErrorState){
    DBLongTimeErrorStateCodeClientId    = 14190001, // 缺少ClientId
    DBLongTimeErrorStateCodeSecret      = 14190002, // 缺少Secret
    DBLongTimeErrorStateCodeToken       = 14190003, // token获取失败
    DBLongTimeErrorNotConnectToServer   = 14190004, // socket链接失败
    DBLongTimeErrorStateNoMicrophone    = 14190005, // 麦克风没有权限
    DBLongTimeErrorStateMicrophoneErr   = 14190006, // 麦克风启动失败
    DBLongTimeErrorStateDataLength      = 14190007, // 数据长度错误
    DBLongTimeErrorStateDataParse       = 14190008, // 服务器返回数据解析失败
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
@interface DBFLongASRClient : NSObject

@property (nonatomic, weak) id <DBFASRClientDelegate> delegate;
/// 音频采样率，支持16000，8000 默认16000
@property (nonatomic, assign) DBLongTimeSampleRate sampleRate;
/// 音频编码格式PCM（文件格式PCM或WAV）SDK目前仅支持PCM
@property (nonatomic, assign) DBLongTimeAudioFormat AudioFormat;
/// 是否在短静音处添加标点，默认为YES
@property (nonatomic, assign) BOOL addPct;
/// 模型名称，必须填写公司购买的语言模型，默认为common
@property (nonatomic, strong) NSString * domain;
/// 1.打印日志 0:不打印日志(打印日志会在沙盒中保存一份text,方便我们查看,上线前要置为NO);
@property (nonatomic, assign) BOOL log;

+ (instancetype)shareInstance;
/// 获取token
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
/// 开启识别
- (void)startSocketAndRecognize;
/// 结束识别,结束识别并且关闭socket与麦克风
- (void)endRecognizeAndCloseSocket;
/// 私有化部署URL
- (void)setupURL:(NSString *)url;

/// 接收识别数据
- (void)webSocketPostData:(NSData *)audioData;

@end

NS_ASSUME_NONNULL_END


