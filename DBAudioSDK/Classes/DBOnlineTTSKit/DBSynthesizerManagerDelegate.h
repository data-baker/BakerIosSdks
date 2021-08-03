//
//  DBSynthesizerManagerDelegate.h
//  DBFlowTTS
//
//  Created by 李明辉 on 2020/8/31.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,DBTTSErrorState) {
    DBErrorFailedCodeClientId    = 11190001, // 缺少ClientId
    DBErrorFailedCodeSecret      = 11190002, // 缺少Secret
    DBErrorFailedCodeToken       = 11190003, // token获取失败
    DBErrorFailedCodeParameters  = 11190004, // 参数未设置
    DBErrorFailedCodeText        = 11190005, // 合成文本内容为空
    DBErrorFailedCodeVoiveName   = 11190006, // 发音人参数错误
    DBErrorFailedCodeResultParse = 11190007, // 解析错误
    DBErrorFailedCodeSynthesis   = 11190008, // 链接服务器失败
};

@protocol DBSynthesizerManagerDelegate <NSObject>

/// 开始合成
- (void)onSynthesisStarted;

/// 流式持续返回数据的接口回调
/// @param data 合成的音频数据，已使用base64加密，客户端需进行base64解密。
/// @param audioType 音频类型，如audio/pcm，audio/mp3。
/// @param interval 音频interval信息。
/// @param endFlag 是否时最后一个数据块，0：否，1：是。
- (void)onBinaryReceivedData:(NSData *)data audioType:(NSString *)audioType interval:(NSString *)interval endFlag:(BOOL)endFlag;

/// 当onBinaryReceived方法中endFlag参数=1，即最后一条消息返回后，会回调此方法。
- (void)onSynthesisCompleted;

/// 合成的第一帧的数据已经得到l，可以在此开启播放功能；
- (void)onPrepared;

/// 合成失败 返回msg内容格式为：{"code":40000,"message":"…","trace_id":" 1572234229176271"}
- (void)onTaskFailed:(DBFailureModel *)failreModel;




@end

NS_ASSUME_NONNULL_END
