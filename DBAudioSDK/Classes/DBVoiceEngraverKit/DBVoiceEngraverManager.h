//
//  DBVoiceCopyManager.h
//  DBVoiceCopyFramework
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DBVoiceModel.h"
#import "DBVoiceDetectionDelegate.h"
#import "DBVoiceEngraverEnumerte.h"
#import "DBTextModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 获取当前录制的Session的进度
typedef void (^DBTextModelArrayHandler)(NSInteger index,NSArray<DBTextModel *> *array,NSString *sessionId);

///  上传识别回调的block
typedef void (^DBVoiceRecogizeHandler)(DBTextModel *model);

/// 获取声音模型的block,多个
typedef void (^DBSuccessModelHandler)(NSArray<DBVoiceModel *> *array);

// 回调声音的模型block，单个
typedef void (^DBSuccessOneModelHandler)(DBVoiceModel  *voiceModel);

/// 失败的回调
typedef void (^DBFailureHandler)(NSError *error);

typedef NS_ENUM(NSUInteger,DBReprintType) {
    DBReprintTypeNormal = 1, // 普通复刻
    DBReprintTypeFine = 2, // 精品复刻
};
@interface DBVoiceEngraverManager : NSObject

/// 录音和错误相关的回调
@property(nonatomic,weak)id<DBVoiceDetectionDelegate>  delegate;

@property(nonatomic,copy,readonly)NSString * accessToken;


// 实例化对象
+ (instancetype )sharedInstance;

/// 初始化SDK，使用分配的clientiD，ClientSecret,其中querId为选填项
/// @param clientId ID
/// @param clientSecret secret
/// @param queryId 查询Id，必填项，用于查询用户复刻的模型
/// @param reprintType 复刻类型
/// @param successHandler 成功回调
/// @param failureHandler 失败回调
- (void)setupWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret queryId:(nullable NSString * )queryId rePrintType:(DBReprintType)reprintType successHandler:(DBMessageHandler)successHandler failureHander:(DBFailureHandler)failureHandler;


/// 获取复刻的录音文本(没有历史会话的录制请求)
//- (void)getRecordTextArrayTextHandler:(DBTextBlock)textHandler failure:(DBFailureHandler)failureHandler __attribute__ ((deprecated("废弃（version >= 1.1.0）,使用`- (void)getTextArrayWithSeesionId:(NSString *)sessionId textHandler:(DBTextBlock)textHandler failure:(DBFailureHandler)failureHandler` 替代")));

// 获取噪音的上限，通过handler进行回调处理
- (void)getNoiseLimit:(DBMessageHandler)handler failuer:(DBFailureHandler)failureHandler;

/// 通过SessionId（恢复录制），如果是首次录制，传入空字符串即可
/// 首次录制会在回调中返回用户的SessionId,后期可以根据该S essionId恢复中途退出的录制；
- (void)getTextArrayWithSeesionId:(NSString *)sessionId textHandler:(DBTextModelArrayHandler)textHandler failure:(DBFailureHandler)failureHandler;


/// 设置查询Id，需要在执行获取sessionId前设置，此参数不是必填参数，但是强烈建议使用
/// @param queryId 查询Id
- (void)setupQueryId:(nullable NSString *)queryId;

// 开始录音，第一次录音会开启一个会话session,如果开启失败会通过failureHandler回调错误
- (void)startRecordWithTextIndex:(NSInteger )textIndex
                  messageHandler:(DBMessageHandler)messageHandler
                   failureHander:(DBFailureHandler)failureHandler;

// 结束录音
- (void)stopRecord;

// 非正常录音结束
- (void)unNormalStopRecordSeesionSuccessHandler:(DBMessageHandler)successBlock failureHandler:(DBFailureHandler)failureHandler;

/// 上传录音的声音到服务器,失败的情况通过代理进行回调
/// @param successHandler 上传成功的回调
- (void)uploadRecordVoiceRecognizeHandler:(DBVoiceRecogizeHandler)successHandler;


/// 查询模型状态
- (void)queryModelStatusByModelId:(NSString *)modelId SuccessHandler:(DBSuccessOneModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler;

/// 批量查询模型状态
/// type ->  1： 普通复刻 2:精品复刻
- (void)batchQueryModelStatusByQueryId:(NSString *)queryId
                              type:(NSString *)type
                        SuccessHandler:(DBSuccessModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler;


/// 开启模型训练
- (void)startModelTrainRecordVoiceWithPhoneNumber:(NSString * _Nullable)phoneNumber
                                        notifyUrl:(NSString *_Nullable)notifyUrl
                                   successHandler:(DBSuccessOneModelHandler)successHandler
                                    failureHander:(DBFailureHandler)failureHandler;




/// 试听音频
/// @param index 当前音频的第几段
- (void)listenAudioWithTextIndex:(NSInteger)index;

/// 停止试听
- (void)stopCurrentListen;

/// 当前的条目能否进入下一条,Yes：可以,NO:不可以
/// @param currentIndex 当前条目的Index
- (BOOL)canNextStepByCurrentIndex:(NSInteger)currentIndex;

/// 当前的复刻类型
- (DBReprintType)currentType;

// sdk版本
+ (NSString *)sdkVersion;
// 获取复刻成功后模型的加载地址
+ (NSString *)ttsIPURL;

/// SDK的日志记录，默认为YES，YES: 开启日志记录， NO:关闭日志记录；
+ (void)enableLog:(BOOL)enableLog;

@end

NS_ASSUME_NONNULL_END
