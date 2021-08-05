//
//  DBTransferProtocol.h
//  DBBVoiceTransfer
//
//  Created by linxi on 2021/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol DBTransferProtocol <NSObject>

// 开启声音转换
- (void)readyToTransfer;

/// 回调麦克风录制的数据 ,isLast: yes,最后一包，NO,非最后一包
- (void)microphoneAudioData:(NSData *)data isLast:(BOOL)isLast;

/// 声音转换结果回调,isLast: Yes: 转换成功 NO: 转换失败
- (void)transferCallBack:(NSData *)data isLast:(BOOL)isLast;


/// 错误回调 code:错误码  message:错误信息
- (void)onError:(NSInteger)code message:(NSString *)message;


@optional

/// 准备好了，可以开始播放了，回调
- (void)readlyToPlay;

/// 播放完成回调
- (void)playFinished;

/// 麦克风获取的音频分贝值回调
- (void)dbValues:(NSInteger)db;

@end

NS_ASSUME_NONNULL_END
