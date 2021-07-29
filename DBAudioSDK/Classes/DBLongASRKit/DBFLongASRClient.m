//
//  DBFASRClient.m
//  Biaobei
//
//  Created by linxi on 2020/9/14.
//  Copyright © 2020 标贝科技. All rights reserved.
//

#import "DBFLongASRClient.h"
#import <DBCommon/DBAuthentication.h>
#import <DBCommon/DBZSocketRocketUtility.h>
#import <DBCommon/DBUncaughtExceptionHandler.h>
#import <DBCommon/DBNetworkHelper.h>
#import <DBCommon/DBLogManager.h>
#import <DBCommon/DBAudioMicrophone.h>
#import "DBLongResponseModel.h"

typedef NS_ENUM(NSUInteger,DBAsrState) {
    DBAsrStateInit  = 0, // 初始化
    DBAsrStateStart = 1, // 开始
    DBAsrStateWillEnd = 2,
    DBAsrStateDidEnd = 3  // 结束
};

static NSString * LongTimeASRSDKVersion = @"1.0.0";

static NSString * LongTimeASRSDKInstallation = @"LongTimeASRSDKInstallation";

static NSString * LongTimeASRSDKStart = @"LongTimeASRSDKStart";

static NSString * DBLongTimeASRUDID = @"DBLongTimeASRUDID";

typedef NS_ENUM(NSUInteger, DBASRUploadLogType){
    DBLongTimeASRUploadLogTypeInstall = 1, // 上传安装统计
    DBLongTimeASRUploadLogTypeStart = 2, // 上传每日打开统计
    DBLongTimeASRUploadLogTypeCrash = 3  // 上传错误日志
};

@interface DBFLongASRClient()<DBAudioMicrophoneDelegate,DBZSocketCallBcakDelegate>

@property(nonatomic,strong) NSMutableDictionary* onlineRecognizeParameters;

@property(nonatomic,copy)NSString  * clientId;

@property(nonatomic,copy)NSString  * clientSecret;

@property(nonatomic,strong)NSString * accessToken;

@property(nonatomic,strong)DBZSocketRocketUtility * socketManager;

@property (strong, nonatomic) DBAudioMicrophone *microphone;
/// 音频序号索引，步长为1递增 0：起始音频帧 >0：中间音频帧（如1 2 3 4 … 1000） -n：结束音频帧（如-1001)
@property (nonatomic, assign) NSInteger idx;

@property (nonatomic, strong) NSString * socketURL;

@property (nonatomic, assign) BOOL flag;

@property (nonatomic,assign) DBAsrState asrState;


@end

@implementation DBFLongASRClient

+ (instancetype)shareInstance {
    static DBFLongASRClient *asrClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asrClient = [[DBFLongASRClient alloc]init];
        DBInstallUncaughtExceptionHandler();
    });
    return asrClient;
}


// MARK: public Methods -
- (void)setupClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret{
    DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
    if (!clientId) {
        failrModel.code = DBLongTimeErrorStateCodeClientId;
        failrModel.message = @"缺少ClientId";
        [self delegateOnfailureModel:failrModel];
        return ;
    }
    if (!clientSecret) {
        failrModel.code = DBLongTimeErrorStateCodeSecret;
        failrModel.message = @"缺少Secret";
        [self delegateOnfailureModel:failrModel];
        return ;
    }
    [self uploadMessage];
    self.clientId = clientId;
    self.clientSecret = clientSecret;
    [DBAuthentication setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
        if (!error) {
            [self logMessage:[NSString stringWithFormat:@"鉴权成功,token = %@",token]];
            self.accessToken = token;
            if (self.delegate && [self.delegate respondsToSelector:@selector(initializationResult:)]) {
                [self.delegate initializationResult:YES];
            }
        }else {
            DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
            failrModel.code = DBLongTimeErrorStateCodeToken;
            failrModel.message = @"获取token失败";
            [self delegateOnfailureModel:failrModel];
            if (self.delegate && [self.delegate respondsToSelector:@selector(initializationResult:)]) {
                [self.delegate initializationResult:NO];
            }
        }
    }];
}


- (void)openMicrophone {
    int sample_rate = 0;
    if (self.sampleRate == DBLongTimeSampleRate8K) {
        sample_rate = 8000;
    }else {
        sample_rate = 16000;
    }
    self.microphone = [[DBAudioMicrophone alloc] initWithSampleRate:sample_rate numerOfChannel:1];
    self.microphone.delegate = self;
    [self logMessage:@"打开麦克风"];
}

// MARK: Publice Methods --
- (void)setupURL:(NSString *)url {
    self.socketURL = url;
    [self logMessage:@"私有化部署url"];
}

- (void)startSocketAndRecognize {
    [self closedAudioResource];
    self.asrState = DBAsrStateStart;
    [self openMicrophone];
    self.idx = 0;
    self.socketManager.timeOut = 6;
    if (self.socketURL.length == 0) {
        self.socketURL = @"wss://asr.data-baker.com/longspeech";
    }
    self.asrState = DBAsrStateInit;
    [self.socketManager DBZWebSocketOpenWithURLString:self.socketURL];
    [self logMessage:@"socket开始链接"];
}


- (void)endRecognizeAndCloseSocket {
    self.asrState = DBAsrStateWillEnd;
}
- (void)closedAudioResource {
    self.asrState = DBAsrStateDidEnd;
    [self.socketManager DBZWebSocketClose];
    [self.microphone stop];
    [self logMessage:@"停止识别"];
    NSLog(@"-------停止识别---------");
}


// MARK: Websocket Delegate Methods
- (void)webSocketDidOpenNote {
    [self logMessage:@"socket链接成功"];
    [self.microphone startRecord];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReady)]){
        [self.delegate onReady];
    }
}

- (void)webSocketdidReceiveMessageNote:(id)object {
    NSString *message = (NSString *)object;
    NSDictionary *dict = [self dictionaryWithJsonString:message];
    NSLog(@"dict%@",dict);
    
    DBLongResponseModel *resModel = [[DBLongResponseModel alloc]init];
    [resModel setValuesForKeysWithDictionary:dict];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(resultTraceId:)]) {
            [self.delegate resultTraceId:dict[@"trace_id"]];
        }
    });
    
    //报错
    if (resModel.code != 90000) {
        [self logMessage:@"后台报错"];
        [self closedAudioResource];
        [self delegateOnfailureModel:resModel];
        return;
    }
    
    
    [self logMessage:[NSString stringWithFormat:@"收到后台消息:%@",resModel.asr_text]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(identifyTheCallback:sentenceEnd:)]) {
            [self.delegate identifyTheCallback:resModel.asr_text sentenceEnd:resModel.sentence_end];
        }
    });
    
    if (resModel.sentence_end && self.asrState == DBAsrStateDidEnd) {
        [self closedAudioResource];
    }
    
}



- (void)webSocketDidCloseNote:(id)object {
    [self logMessage:@"socket关闭"];
}

- (void)webSocketdidConnectFailed:(id)object {
    DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
    failrModel.code = DBLongTimeErrorNotConnectToServer;
    failrModel.message = @"socket连接失败";
    [self delegateOnfailureModel:failrModel];
}

// MARK: DBAudioMicrophoneDelegate methods
- (void)audioMicrophone:(DBAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize {
    
    if (self.asrState == DBAsrStateDidEnd) {
        return;
    }
    
    if (self.asrState == DBAsrStateWillEnd) { // 如果准备结束了，不再继续回调数据
        self.asrState = DBAsrStateDidEnd;
        NSData*data = [[NSData alloc]initWithBytes:pcmByte length:byteSize];
        [self webSocketPostData:data];
        return;
    }
    
    NSData*data = [[NSData alloc]initWithBytes:pcmByte length:byteSize];
    [self webSocketPostData:data];
}


- (void)webSocketPostData:(NSData *)audioData {
    
    if (audioData.length != 5120) {
        DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
        failrModel.code = DBLongTimeErrorStateDataLength;
        failrModel.message = @"数据长度错误";
        [self delegateOnfailureModel:failrModel];
    }
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSData *base64Data = [audioData base64EncodedDataWithOptions:0];
    NSString *audioString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    parameter[@"audio_data"]= audioString;
    
    if (self.AudioFormat == DBLongTimeAudioFormatWAV) {
        parameter[@"audio_format"] = @"WAV";
    }else {
        parameter[@"audio_format"] = @"PCM";
    }
    
    if (self.sampleRate == DBLongTimeSampleRate8K) {
        parameter[@"sample_rate"] = @(8000);
    }else {
        parameter[@"sample_rate"] = @(16000);
    }
    
    if (self.asrState == DBAsrStateDidEnd) {
        parameter[@"req_idx"]= @(-self.idx);
    }else {
        parameter[@"req_idx"]= @(self.idx);
    }

    parameter[@"speech_type"] =  @(1);
    
    if (self.flag) {
        parameter[@"add_pct"] = @(self.addPct);
    }else {
        parameter[@"add_pct"] = @(true);
    }
    
    if (self.domain) {
        parameter[@"domain"] = self.domain;
    }else {
        parameter[@"domain"] = @"common";
    }
    
    self.onlineRecognizeParameters[@"asr_params"] = parameter;
    self.onlineRecognizeParameters[@"version"] = @"1.0";
    self.onlineRecognizeParameters[@"access_token"] = self.accessToken;
    
    NSString *paramString = [self dictionaryToJson:self.onlineRecognizeParameters];
    NSLog(@"paramString:%@",paramString);

    [self.socketManager sendData:paramString];
    self.idx++; //全局语音包序号
    self.onlineRecognizeParameters[@"asr_params"][@"audio_data"] = @"5120字节数据";
    [self logMessage:[NSString stringWithFormat:@"上传数据:%@",self.onlineRecognizeParameters]];
}

-(void)audioCallBackVoiceGrade:(NSInteger)grade {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(dbValues:)]) {
            [self.delegate dbValues:grade];
        }
    });
   
}

-(void)microphoneonError:(NSInteger)code message:(NSString *)message {
    [self closedAudioResource];
    DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
    if (code == 10190001) {
        failrModel.code = DBLongTimeErrorStateNoMicrophone;
    }else {
        failrModel.code = DBLongTimeErrorStateMicrophoneErr;
    }
    failrModel.message = message;
    [self delegateOnfailureModel:failrModel];
}

- (void)delegateOnfailureModel:(DBLongResponseModel *)model{
    [self logMessage:[NSString stringWithFormat:@"错误码:%ld 错误信息:%@",model.code,model.message]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onError:message:)]) {
            [self.delegate onError:model.code message:model.message];
        }
    });
   
}

#pragma -mark 工具
// 上传统计信息
- (void)uploadMessage {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"DBLongTimeDo_not_upload"]) {
        [self logMessage:@"不进行统计上报"];
        return;
    }
    
    if ([[userDefaults valueForKey:DBLongTimeASRUDID] isEqualToString:@""] || [userDefaults valueForKey:DBLongTimeASRUDID] == nil) {
        [userDefaults setValue:[self createUuid] forKey:DBLongTimeASRUDID];
        [userDefaults synchronize];
    }
    
    if (![userDefaults boolForKey:LongTimeASRSDKInstallation]) {
        [userDefaults setBool:YES forKey:LongTimeASRSDKInstallation];
        [userDefaults synchronize];
        //TODO:上传首次安装信息
        [self upLoadLogWithType:DBLongTimeASRUploadLogTypeInstall];
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    
    if (![[userDefaults valueForKey:LongTimeASRSDKStart] isEqualToString:str]) {
        [userDefaults setValue:str forKey:LongTimeASRSDKStart];
        [userDefaults synchronize];
        //TODO:上传每日启动信息
        [self upLoadLogWithType:DBLongTimeASRUploadLogTypeStart];
    }
    
    //TODO:上传错误日志
    [self upLoadLogWithType:DBLongTimeASRUploadLogTypeCrash];
}

-(NSString*)createUuid{
    char data[32];
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

- (void)upLoadLogWithType:(DBASRUploadLogType)type {
    NSString * errorInfo;
    NSString * path = [DBUncaughtExceptionHandler shareInstance].exceptionFilePath;
    if (type == DBLongTimeASRUploadLogTypeCrash) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            [self logMessage:@"没有错误日志"];
            return;
        }else {
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
    parameters[@"sdkUuid"] = [userDefaults valueForKey:DBLongTimeASRUDID];//唯一标志一个客户端 ,
    parameters[@"sdkVersion"] = LongTimeASRSDKVersion;//sdk版本 ,
    parameters[@"submitType"] = [NSString stringWithFormat:@"%zd",type];//提交类型：1首次激活 2日常上报 3错误上报
    parameters[@"sdkName"] = @"LongTimeASR";//区分sdk是asr,tts等SDK类型
    
    [DBNetworkHelper postWithUrlString:@"https://sdkinfo.data-baker.com:8677/sdk-submit/sdk-info/sign-upload" parameters:parameters success:^(NSDictionary * _Nonnull data) {
        if ([data[@"code"] intValue] == 40005) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"DBLongTimeDo_not_upload"];
            [userDefaults synchronize];
        }else if ([data[@"code"] intValue] == 20000) {
            switch (type) {
                case DBLongTimeASRUploadLogTypeInstall:
                    [self logMessage:@"按装信息上传成功"];
                    break;
                case DBLongTimeASRUploadLogTypeStart:
                    [self logMessage:@"启动信息上传成功"];
                    break;
                case DBLongTimeASRUploadLogTypeCrash:{
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if ([fileManager removeItemAtPath:path error:nil]) {
                        [self logMessage:@"崩溃记录文件删除成功"];
                    }
                }
                    break;
            }
        }else {
            switch (type) {
                case DBLongTimeASRUploadLogTypeInstall:
                    [self logMessage:@"按装信息上传失败"];
                    break;
                case DBLongTimeASRUploadLogTypeStart:
                    [self logMessage:@"启动信息上传失败"];
                    break;
                case DBLongTimeASRUploadLogTypeCrash:
                    [self logMessage:@"崩溃记录文件删除失败"];
                    break;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        switch (type) {
            case DBLongTimeASRUploadLogTypeInstall:
                [self logMessage:@"按装信息上传失败"];
                break;
            case DBLongTimeASRUploadLogTypeStart:
                [self logMessage:@"启动信息上传失败"];
                break;
            case DBLongTimeASRUploadLogTypeCrash:
                [self logMessage:@"崩溃记录文件删除失败"];
                break;
        }
    }];
}

// 记录运行日志
- (void)logMessage:(NSString *)string {
    if (self.log) {
        NSLog(@"运行日志:%@",string);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [DBLogManager saveCriticalSDKRunData:string fileName:@"DBLongTimeASR"];
        });
    }
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        DBLongResponseModel *failrModel = [[DBLongResponseModel alloc]init];
        failrModel.code = DBLongTimeErrorStateDataParse;
        failrModel.message = @"服务器返回数据解析失败";
        [self delegateOnfailureModel:failrModel];
        return nil;
    }
    return dic;
}

// MARK: Custom Methods -

- (DBZSocketRocketUtility *)socketManager {
    if (!_socketManager) {
        _socketManager = [DBZSocketRocketUtility instance];
        _socketManager.delegate = self;
    }
    return _socketManager;
}

-(NSMutableDictionary *)onlineRecognizeParameters {
    if (!_onlineRecognizeParameters) {
        _onlineRecognizeParameters = [[NSMutableDictionary alloc]init];
    }
    return _onlineRecognizeParameters;;
}

-(void)setAddPct:(BOOL)addPct {
    _addPct = addPct;
    self.flag = YES;
}

@end
