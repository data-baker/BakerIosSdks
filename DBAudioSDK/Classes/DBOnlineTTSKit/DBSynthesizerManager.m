//
//  DBSocketManager.m
//  DBTTSScocketSDK
//
//  Created by linxi on 2019/11/13.
//  Copyright © 2019 newbike. All rights reserved.
//

#import "DBSynthesizerManager.h"
#import "DBTextSplitUtil.h"
//#import <DBCommon/DBSynthesisPlayer.h>
#import "DBSynthesisPlayer.h"
//#import <DBCommon/DBNetworkHelper.h>
#import "DBNetworkHelper.h"
//#import <DBCommon/DBAuthentication.h>
#import "DBAuthentication.h"
//#import <DBCommon/DBUncaughtExceptionHandler.h>
#import "DBUncaughtExceptionHandler.h"
#import "DBSynthesizer.h"
//#import <DBCommon/DBLogManager.h>
#import "DBLogManager.h"
// TODO:更新前修改版本号
static NSString * TTSSDKVersion = @"2.2.5";

static NSString * TTSSDKInstallation = @"TTSSDKInstallation";

static NSString * TTSSDKStart = @"TTSSDKStart";

static NSString * DBTTSUDID = @"DBTTSUDID";

typedef NS_ENUM(NSUInteger, DBUploadLogType){
    DBUploadLogTypeInstall = 1, // 上传安装统计
    DBUploadLogTypeStart = 2, // 上传每日打开统计
    DBUploadLogTypeCrash = 3  // 上传错误日志
};

@interface DBSynthesizerManager ()<DBSynthesizerDelegate,DBSynthesizerManagerDelegate,DBSynthesisPlayerDelegate>

@property(nonatomic,strong)DBSynthesizer * synthesizer;
/// 请求合成的参数
@property(nonatomic,strong)DBSynthesizerRequestParam *synthesizerReuestPara;
/// 在线合成的请求参数
@property(nonatomic,strong)NSMutableDictionary *onlineSynthesizerParameters;

@property(nonatomic,copy)NSString  * accessToken;

@property(nonatomic,copy)NSString  * clientId;

@property(nonatomic,copy)NSString  * clientSecret;

@property(nonatomic,strong)NSMutableArray * textArray;
/// 要合成的文本的总长度
@property(nonatomic,copy)NSString * allSynthesisText;
///  socket连接的url
@property(nonatomic,copy)NSString * socketUrl;

/// 播放器
@property(nonatomic,strong)DBSynthesisPlayer * synthesisDataPlayer;



@end

@implementation DBSynthesizerManager



-(instancetype)init {
    if (self = [super init]) {
        [self logMessage:@"初始化合成控制器"];
        self.textArray = [NSMutableArray array];
        self.synthesizer = [[DBSynthesizer alloc]init];;
        self.synthesizer.synthesizerDelegate = self;
        self.synthesizer.delegate = self;
        [self logMessage:@"初始化崩溃处理器"];
        DBInstallUncaughtExceptionHandler();
    }
    return self;
}

-(void)setLog:(BOOL)log {
    _log = log;
    _synthesizer.log = log;
}

- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret handler:(DBMessageHandler)handler{
    
    NSAssert(handler != nil, @"handler不能等于nil");
    
    DBFailureModel *failrModel = [[DBFailureModel alloc]init];
    
    if (!clientId) {
        failrModel.code = DBErrorFailedCodeClientId;
        failrModel.message = @"请填写ClientId";
        [self delegateOnfailureModel:failrModel];
        return ;
    }
    if (!clientSecret) {
        failrModel.code = DBErrorFailedCodeSecret;
        failrModel.message = @"请填写Secret";
        [self delegateOnfailureModel:failrModel];
        return ;
    }
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    
    [self logMessage:[NSString stringWithFormat:@"clientId = %@",clientId]];
    [self logMessage:[NSString stringWithFormat:@"clientSecret = %@",clientSecret]];

    [self uploadMessage];
    
    [DBAuthentication setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (!error) {
            [self logMessage:[NSString stringWithFormat:@"鉴权成功,token = %@",token]];
            self.accessToken = token;
            handler(YES,token);
        }else {
            handler(NO,@"鉴权失败");
            DBFailureModel *failrModel = [[DBFailureModel alloc]init];
            failrModel.code = DBErrorFailedCodeToken;
            failrModel.message = @"获取token失败";
            [self delegateOnfailureModel:failrModel];
            
        }
    }];
}

- (void)setupPrivateDeploymentURL:(NSString *)url {
    [self logMessage:@"设置私有化socket链接"];
    [self uploadMessage];
    self.socketUrl = url;
    [self.synthesizer setupPrivateDeploymentURL:url];
}

/// 重写setter方法，如果设置播放器那么将播放器为数据的回调
/// @param synthesisDataPlayer  pcm的播放器
- (void)setSynthesisDataPlayer:(DBSynthesisPlayer *)synthesisDataPlayer {
    [self logMessage:@"播放器设置成功成功"];
    _synthesisDataPlayer = synthesisDataPlayer;
}

//MARK: 设置参数
// 从外部设置参数
- (NSInteger)setSynthesizerParams:(DBSynthesizerRequestParam *)requestParam {
    [self logMessage:[NSString stringWithFormat:@"设置参数为 = %@",requestParam]];
    return  [self setSynthesizerParams:requestParam isFromOut:YES];
}
// 从内部设置参数，内部循环播放时会一直调用这个接口
 - (NSInteger)setSynthesizerParams:(DBSynthesizerRequestParam *)requestParam isFromOut:(BOOL)fromOut {
     self.synthesizerReuestPara = requestParam;

     if (fromOut) {
        [self setSynthesisText:requestParam.text];
     }
     requestParam.text = self.synthesizerReuestPara.text;
     NSInteger ret = [self checkSynthesisParameters:requestParam isFromOut:fromOut];
     if (ret != 0) {
         return DBErrorFailedCodeParameters;
     }
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
     parameters[@"voice_name"]= requestParam.voice;
     NSString *text64Sting = [self base64EncodeString:requestParam.text];
     parameters[@"text"]= text64Sting;
     // 默认中文
     if (!requestParam.language|| requestParam.language.length == 0) {
//         requestParam.language = @"ZH";
         //
         requestParam.language = @"SCH";

     }
     parameters[@"language"] = requestParam.language;

     // 语速默认5
     if (!requestParam.speed) {
         requestParam.speed = @"5";
     }
     
     parameters[@"speed"] = requestParam.speed;
     // 音调默认5
     if (!requestParam.pitch) {
         requestParam.pitch = @"5";
     }
     
     parameters[@"pitch"] = requestParam.pitch;
     // 声音类型，默认pcm 16k
     if (!requestParam.audioType) {
         requestParam.audioType = DBParamAudioTypePCM16K;
     }
     parameters[@"audiotype"] = @(requestParam.audioType).stringValue;
     // 码率，默认16k
     if (!requestParam.rate) {
         requestParam.rate = DBTTSRate16k;
     }
     // 如果是wav的数据格式，rate默认设置为1
//     if (requestParam.audioType == DBTTSAudioTypeWAV16K) {
//         requestParam.rate = DBTTSRate8k;
//     }
     parameters[@"rate"] = @(requestParam.rate).stringValue;
     parameters[@"domain"]= @"1";
     parameters[@"interval"] = @"1";

     self.onlineSynthesizerParameters[@"tts_params"] = parameters;
     self.onlineSynthesizerParameters[@"version"] = @"1.0";
     if (self.socketUrl) {
         self.onlineSynthesizerParameters[@"access_token"] = @"default";
     }else {
         self.onlineSynthesizerParameters[@"access_token"] = self.accessToken;
     }
     return 0;
 }


- (void)setSynthesisText:(NSString *)synthesisText {
    self.allSynthesisText = synthesisText;
    DBTextSplitUtil *util = [[DBTextSplitUtil alloc]init];
    self.textArray = [[util splitTextArrayWithAllText:synthesisText] mutableCopy];
    [self logMessage:[NSString stringWithFormat:@"合成文本为 = %@",self.textArray]];
    if (self.textArray.count > 0) {
        self.synthesizerReuestPara.text = self.textArray[0];
        [self.textArray removeObjectAtIndex:0];
    }else {
        self.synthesizerReuestPara.text = synthesisText;
        [self.textArray removeAllObjects];
    }
}

// MARK: private Method

- (NSInteger)checkSynthesisParameters:(DBSynthesizerRequestParam *)requestParam isFromOut:(BOOL)fromOut{
    DBFailureModel *failureModel = [[DBFailureModel alloc]init];
    if (!requestParam) {
        failureModel.code = DBErrorFailedCodeParameters;
        failureModel.message = @"请设置参数";
        [self delegateOnfailureModel:failureModel];
        return DBErrorFailedCodeParameters;
    }
    if (!requestParam.voice) {
        failureModel.message = @"请设置发音人";
        failureModel.code = DBErrorFailedCodeVoiveName;
        [self delegateOnfailureModel:failureModel];
        return DBErrorFailedCodeVoiveName;
    }
    
    if (!requestParam.text) {
        failureModel.code = DBErrorFailedCodeText;
        failureModel.message = @"请设置合成文本";
        [self delegateOnfailureModel:failureModel];
        return DBErrorFailedCodeText;
    }
    if (fromOut) {
        [self logMessage:@"参数设置成功"];
    }
    
    return 0;
}

- (void)delegateOnfailureModel:(DBFailureModel *)failureModel {
    [self logMessage:[NSString stringWithFormat:@"错误:%@",failureModel.message]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskFailed:)]) {
        [self.delegate onTaskFailed:failureModel];
    }
}

// MARK: 合成控制
- (void)cycleStart{
    self.synthesizer.onlineSynthesizerParameters = self.onlineSynthesizerParameters;
    self.synthesizer.timeOut = self.timeOut;
    [self.synthesizer start];
}
- (void)start{
    self.synthesizer.onlineSynthesizerParameters = self.onlineSynthesizerParameters;
    self.synthesizer.timeOut = self.timeOut;
    self.synthesizer.synthesizerIndex = 0;
    [self.synthesizer start];
}

- (void)stop {
    [self.synthesizer stop];
}

- (void)cancel {
    [self.synthesizer stop];
    if (self.synthesisDataPlayer) {
        [self.synthesisDataPlayer stopPlay];
    }
}

- (void)pausePlay {
    [self.synthesisDataPlayer pausePlay];
}

- (void)resumePlay {
    [self.synthesisDataPlayer startPlay];
}

- (void)startPlayNeedSpeaker:(BOOL)needSpeaker {
    if (needSpeaker) {
        self.synthesisDataPlayer = [[DBSynthesisPlayer alloc]init];
        self.synthesisDataPlayer.delegate = self;
    }
    [self start];
}

- (void)releaseInstance {
    
}

/// 当前播放器的播放状态
- (BOOL)isPlayerPlaying {
    return self.synthesisDataPlayer.isPlayerPlaying;
}

- (NSInteger)currentPlayPosition {
    return self.synthesisDataPlayer.currentPlayPosition;
}

- (NSInteger)audioLength {
    return self.synthesisDataPlayer.audioLength;
}

/// 链接成功
- (void)onSynthesisStarted {
    [self logMessage:@"————————————————————链接成功,开始合成————————————————————"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSynthesisStarted)]) {
        [self.delegate onSynthesisStarted];
    }
}

/// 流式持续返回数据的接口回调
/// @param data 合成的音频数据，已使用base64加密，客户端需进行base64解密。
/// @param audioType 音频类型，如audio/pcm，audio/mp3。
/// @param interval 音频interval信息。
/// @param endFlag 是否时最后一个数据块，0：否，1：是。
- (void)onBinaryReceivedData:(NSData *)data audioType:(NSString *)audioType interval:(NSString *)interval endFlag:(BOOL)endFlag {
    if (self.synthesisDataPlayer) {
        [self logMessage:@"给播放器添加播放数据"];
        [self.synthesisDataPlayer appendData:data totalDatalength:self.allSynthesisText.length endFlag:self.synthesisDataPlayer.finished];
    }
    BOOL finalEndFlag = endFlag && self.textArray.count == 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBinaryReceivedData:audioType:interval:endFlag:)]) {
        [self.delegate onBinaryReceivedData:data audioType:audioType interval:interval endFlag:finalEndFlag];
    }
}

/// 当onBinaryReceived方法中endFlag参数=1，即最后一条消息返回后，会回调此方法。
- (void)onSynthesisCompleted {
    if (self.textArray.count >0) {
        [self logMessage:@"开始合成下一段文本"];
        self.synthesizerReuestPara.text = [self.textArray firstObject];
        [self.textArray removeObjectAtIndex:0];
        [self setSynthesizerParams:self.synthesizerReuestPara isFromOut:NO];
        [self cycleStart];
    }else {
        [self logMessage:@"————————————————————合成完成了——————————————————————"];
        [self stop];
        if (self.synthesisDataPlayer) {
            self.synthesisDataPlayer.finished = YES;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSynthesisCompleted)]) {
            [self.delegate onSynthesisCompleted];
        }
    }
}


/// 合成的第一帧的数据已经得到了
- (void)onPrepared {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPrepared)]) {
        [self.delegate onPrepared];
    }
}
/// 合成失败 返回msg内容格式为：{"code":40000,"message":"…","trace_id":" 1572234229176271"}
- (void)onTaskFailed:(DBFailureModel *)failreModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskFailed:)]) {
        [self.delegate onTaskFailed:failreModel];
    }
}


//MARK: player Delegate


- (void)readlyToPlay {
    if (self.synthesisDataPlayer.isReadyToPlay && self.synthesisDataPlayer.isPlayerPlaying == NO) {
        [self.synthesisDataPlayer startPlay];
    }
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(readlyToPlay)]) {
        [self.playerDelegate readlyToPlay];
    }
    
}

- (void)playFinished {
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(playFinished)]) {
        [self.playerDelegate playFinished];
    }
}

- (void)playPausedIfNeed {
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(playPausedIfNeed)]) {
        [self.playerDelegate playPausedIfNeed];
    }

}

- (void)playResumeIfNeed  {
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(playResumeIfNeed)]) {
        [self.playerDelegate playResumeIfNeed];
    };
}

- (void)updateBufferPositon:(float)bufferPosition {
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(updateBufferPositon:)]) {
        [self.playerDelegate updateBufferPositon:bufferPosition];
    };
}
- (void)playerFaiure:(NSString *)errorStr {
    
    if (self.playerDelegate && [self.playerDelegate respondsToSelector:@selector(playerFaiure:)]) {
        [self.playerDelegate playerFaiure:errorStr];
    };
}


// MARK: ------ DBSynthesizerDelegate -----
/// 鉴权失败重新获取token
- (void)refreshToken:(DBMessageHandler)handler {
    [self setupClientId:self.clientId clientSecret:self.clientSecret handler:handler];
}



// base64编码
-(NSString *)base64EncodeString:(NSString *)baseString {
    NSString *encodeString = [baseString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *data = [encodeString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodeString = [data base64EncodedStringWithOptions:0]; //编码
    return base64EncodeString;
}

// MARK: 打印错误日志
- (void)logMessage:(NSString *)message {
    if (self.islog) {
//        NSLog(@"%@",message);
        [DBLogManager saveCriticalSDKRunData:message];
    }
}

- (void)uploadMessage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"DBDo_not_upload"]) {
        return;
    }
    
    if ([[userDefaults valueForKey:DBTTSUDID] isEqualToString:@""] || [userDefaults valueForKey:DBTTSUDID] == nil) {
        [userDefaults setValue:[self createUuid] forKey:DBTTSUDID];
        [userDefaults synchronize];
    }
    
    if (![userDefaults boolForKey:TTSSDKInstallation]) {
        [userDefaults setBool:YES forKey:TTSSDKInstallation];
        [userDefaults synchronize];
        //TODO:上传首次安装信息
        [self upLoadLogWithType:DBUploadLogTypeInstall];
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    
    if (![[userDefaults valueForKey:TTSSDKStart] isEqualToString:str]) {
        [userDefaults setValue:str forKey:TTSSDKStart];
        [userDefaults synchronize];
        //TODO:上传每日启动信息
        [self upLoadLogWithType:DBUploadLogTypeStart];
    }
    
    //TODO:上传错误日志
    [self upLoadLogWithType:DBUploadLogTypeCrash];
}

-(NSString*)createUuid;{
    char data[32];
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

- (void)upLoadLogWithType:(DBUploadLogType)type {
    NSString * errorInfo;
    NSString * path = [DBUncaughtExceptionHandler shareInstance].exceptionFilePath;
    if (type == DBUploadLogTypeCrash) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            [self logMessage:@"没有错误日志"];
            return;
        }else {
            [self logMessage:@"有错误日志"];
            NSError *error = nil;
            errorInfo = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error != nil) {
                [self logMessage:@"获取错误日志失败"];
                return;
            }
        }
    }
    
    NSString * bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    parameters[@"errorInfo"] = errorInfo;//错误详情 ,
    parameters[@"packageName"] = bundleID;//sdk包名 ,
    parameters[@"sdkClientId"] = self.clientId;//授权clientId ,
    parameters[@"sdkType"] = @"iOS";//sdk类型：IOS/ANDROID/JAVA/... ,
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    parameters[@"sdkUuid"] = [userDefaults valueForKey:DBTTSUDID];//唯一标志一个客户端 ,
    parameters[@"sdkVersion"] = TTSSDKVersion;//sdk版本 ,
    parameters[@"submitType"] = [NSString stringWithFormat:@"%zd",type];//提交类型：1首次激活 2日常上报 3错误上报
    parameters[@"sdkName"] = @"tts";//区分sdk是asr,tts等SDK类型
    
    [DBNetworkHelper postWithUrlString:@"https://sdkinfo.data-baker.com:8677/sdk-submit/sdk-info/sign-upload" parameters:parameters success:^(NSDictionary * _Nonnull data) {
        if ([data[@"code"] intValue] == 40005) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"DBDo_not_upload"];
            [userDefaults synchronize];
        }else if ([data[@"code"] intValue] == 20000) {
            switch (type) {
                case DBUploadLogTypeInstall:
                    [self logMessage:@"按装信息上传成功"];
                    break;
                case DBUploadLogTypeStart:
                    [self logMessage:@"启动信息上传成功"];
                    break;
                case DBUploadLogTypeCrash:{
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if ([fileManager removeItemAtPath:path error:nil]) {
                        [self logMessage:@"崩溃记录文件删除成功"];
                    }
                }
                    break;
            }
        }else {
            switch (type) {
                case DBUploadLogTypeInstall:
                    [self logMessage:@"按装信息上传失败"];
                    break;
                case DBUploadLogTypeStart:
                    [self logMessage:@"启动信息上传失败"];
                    break;
                case DBUploadLogTypeCrash:
                    [self logMessage:@"崩溃记录文件删除失败"];
                    break;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        switch (type) {
            case DBUploadLogTypeInstall:
                [self logMessage:@"按装信息上传失败"];
                break;
            case DBUploadLogTypeStart:
                [self logMessage:@"启动信息上传失败"];
                break;
            case DBUploadLogTypeCrash:
                [self logMessage:@"崩溃记录文件删除失败"];
                break;
        }
    }];
}




// MARK: - custom Accessor -
- (NSMutableDictionary *)onlineSynthesizerParameters {
    if (!_onlineSynthesizerParameters) {
        _onlineSynthesizerParameters = [NSMutableDictionary dictionary];
    }
    return _onlineSynthesizerParameters;
}
- (NSString *)ttsSdkVersion {
    if (!_ttsSdkVersion) {
        _ttsSdkVersion = TTSSDKVersion;
    }
    return _ttsSdkVersion;
}

@end
