//
//  DBOfflineTransferVoiceClient.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/10/26.
//

#import <Foundation/Foundation.h>
#import "DBOfflineVoiceConvertDelegate.h"

typedef void (^DBMessagHandler)(NSInteger ret, NSString * _Nullable message);

NS_ASSUME_NONNULL_BEGIN

@interface DBOfflineConvertVoiceClient : NSObject

/// 回调代理对象
@property(nonatomic,weak)id <DBOfflineVoiceConvertDelegate> delegate;

/// 1.打印日志 0:不打印日志(打印日志会在沙盒中保存一份text,方便我们查看,上线前要置为NO);
@property (nonatomic, assign) BOOL log;

///  示例化方法
+ (instancetype)shareInstance;
///  初始化SDK
- (void)setupVoiceConvertSDKClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret messageHander:(DBMessagHandler)messageHandler;

/// 设置发音人，
- (void)setupVoiceName:(NSString *)voiceName;

/// 开启录音
- (void)startAndRecord;

/// 结束录音
- (void)stopRecord;

/*
 播放转换后的声音文件
 此播放是在转换完成后，调用有效
 若在转换未完成此前调用了play, 给出错误提示
 */
- (void)play;

- (void)pause;

- (void)stopPlay;

/// 开启转换本地的音频数据为麦克风收录的数据
- (void)startFileConvert;

/*
 客户自有数据需转换的情况
 */
- (void)startConvertByPCM;

/*
 自有数据传输方式,
 endFlag:0:首包 (1..N-1)： 持续输入 -N：最后一包
 data:接收16K采样率16bit位深数据 每一包需固定5120长度，最后一包可随意
 */
- (void)sendData:(NSData *)data endFlag:(NSInteger)flag;


/// 返回原始录音文件的路径
- (NSString *)getOriginRecordFile;

/// 获取转换后录音文件的路径
- (NSString *)getConvertResultFile;

@end

NS_ASSUME_NONNULL_END
