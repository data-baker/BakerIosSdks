//
//  DBSocketManager.h
//  DBTTSScocketSDK
//
//  Created by linxi on 2019/11/13.
//  Copyright © 2019 newbike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSynthesizerRequestParam.h"
#import "DBFailureModel.h"
#import "DBSynthesizerManagerDelegate.h"
#import <DBCommon/DBSynthesisPlayer.h>


@class DBSynthesisPlayer;

NS_ASSUME_NONNULL_BEGIN

typedef void(^DBMessageHandler)(BOOL ret,NSString * message);

@interface DBSynthesizerManager : NSObject

// 合成器的回调
@property(nonatomic,weak)id <DBSynthesizerManagerDelegate> delegate;

// 合成播放器的回调
@property(nonatomic,weak)id <DBSynthesisPlayerDelegate> playerDelegate;


///超时时间,默认15s
@property(nonatomic,assign)NSInteger  timeOut;

/// 当前的播放状态
@property(nonatomic,assign,readonly,getter=isPlayerPlaying)BOOL playerPlaying;

/// 当前的播放进度
@property(nonatomic,assign,readonly)NSInteger currentPlayPosition;

/// 音频总长度
@property(nonatomic,assign,readonly)NSInteger audioLength;

/// 1:打印日志 0：不打印日志,默认不打印日志
@property(nonatomic,assign,getter=islog)BOOL log;

/// SDK的版本
@property(nonatomic,copy)NSString * ttsSdkVersion;


/// 鉴权方法
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret handler:(DBMessageHandler)handler;

// 近针对私有化授权的服务使用，调用此方法后无需设置clientIf和clientSecret
- (void)setupPrivateDeploymentURL:(NSString *)url;
/**
 * @brief 设置SynthesizerRequestParam对象参数,返回值为0,表示设置参数成功
 */
-(NSInteger)setSynthesizerParams:(DBSynthesizerRequestParam *)requestParam;

///// 开始合成
//- (void)start;
///  停止合成


/// 开始合成
/// @param needSpeaker yes:需要播放器，需要调用者注册成为DBSynthesisPlayerDelegate和DBSynthesizerManagerDelegate的回调者
///   NO: 不需要播放器，需要者成为DBSynthesizerManagerDelegate的回调这
- (void)startPlayNeedSpeaker:(BOOL)needSpeaker;

/// 暂停播放
- (void)pausePlay;

/// 继续播放
- (void)resumePlay;

// 取消本次合成并停止朗读
- (void)cancel;


@end



NS_ASSUME_NONNULL_END
