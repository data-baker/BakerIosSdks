//
//  DBOfflineVoiceConvertProtocol.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/10/27.
//

#import <Foundation/Foundation.h>
#import "DBOfflineVoiceConvertEnum.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DBOfflineVoiceConvertDelegate <NSObject>

@required
/*
 data: 转换后的数据
 endFlag: 转换结束的标识，Yes: 转换完成， No: 未完成
 */
- (void)onResultData:(NSData *)data endflag:(BOOL)endFlag;

/*
 errorCode: 错误码
 msg: 错误信息
 */
- (void)onError:(NSString *)errorCode msg:(NSString *)message;


@optional
/// 麦克风获取的音频分贝值回调
- (void)dbValues:(NSInteger)db;

/// 在录音启动后，回调
- (void)onReadyForConvert;


/*
 转换完成
 */
- (void)onConvertComplete;

- (void)onPlaying;

- (void)onPaused;

- (void)onPlayCompleted;

- (void)onStopped;


@end

NS_ASSUME_NONNULL_END
