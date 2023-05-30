//
//  DBVoiceTransferUtil.h
//  DBBVoiceTransfer
//
//  Created by linxi on 2021/3/18.
//

#import <Foundation/Foundation.h>
#import "DBTransferProtocol.h"
//#import <DBCommon/DBSynthesisPlayer.h>
//#import <DBCommon/DBAuthentication.h>
#import "DBAuthentication.h"
#import "DBTransferEnum.h"
#import "DBTransferModel.h"


NS_ASSUME_NONNULL_BEGIN


@interface DBVoiceTransferUtil : NSObject

/// 回调代理对象
@property(nonatomic,weak)id <DBTransferProtocol> delegate;

/// 1.打印日志 0:不打印日志(打印日志会在沙盒中保存一份text,方便我们查看,上线前要置为NO);
@property (nonatomic, assign) BOOL log;

// true代表启动服务端vad功能，默认false。如果启动系统会根据输入音频进行检测，过滤环境噪音。否则直接将原始输入音频进行转换。
@property(nonatomic,assign)BOOL enableVad;

// true代表输出音频与输入音频进行对齐,默认false。即开启vad时会保留静音部分，false丢弃静音部分
@property(nonatomic,assign)BOOL align_input;


// 发音人
@property(nonatomic,copy)NSString * voiceName;


+ (instancetype)shareInstance;
/// 获取token
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret block:(DBAuthenticationBlock)block;

/// 开始转换，是否需要播放
/// @param needPlay True: 需要播放； Flase:不需要播放
- (void)startTransferNeedPlay:(BOOL)needPlay;

/// 结束转换并且关闭socket与麦克风
- (void)endTransferAndCloseSocket;

/// 本地文件转换，读取本地文件
/// @param needPlay True: 需要播放； Flase:不需要播放
- (void)startTransferWithFilePath:(NSString *)filePath needPaley:(BOOL)needPlay;

/// 结束文件变声转换并且关闭服务端连接
- (void)endFileTransferAndCloseSocket;


/// 默认保存在Temp文件夹下
/// @param fileName 文件名称
- (NSString *)getSavePath:(NSString *)fileName;

/// 先开启网络连接，接收到网络连接成功回调后再通过`webSocketPostData:isEnd`发送音频数据
- (void)startServeConnetNeedPlay:(BOOL)needPlay;

/// 向服务端发送数据
/// @param audioData 音频数据
/// @param isEnd 最后一包数据时isEnd设置为Yes,否则设置为NO
- (void)webSocketPostData:(NSData *)audioData isEnd:(BOOL)isEnd;

/// 停止播放
- (void)stopPlay;

+ (NSString *)sdkVersion;


@end

NS_ASSUME_NONNULL_END
