//
//  DBVoiceCopyManager.m
//  DBVoiceCopyFramework
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceEngraverManager.h"
#import <AVFoundation/AVFoundation.h>
#import "DBVoiceEngraverEnumerte.h"
#import "DBEngraverAudioMicrophone.h"
#import "DBEngraverNetworkHelper.h"
#import "DBZSocketRocketUtility.h"
#import "DBParamsDelegate.h"
#import "DBRecordPCMDataPlayer.h"
#import "DBLogManager.h"
#import "DBAuthentication.h"
#import "DBTextModel.h"

static NSString *const ttsIPURL  = @"http://10.10.50.18:8001/tts_personal";

@interface DBVoiceEngraverManager ()<DBAudioMicrophoneDelegate,DBRecordPCMDataPlayerDelegate,DBUpdateTokenDelegate,DBZSocketCallBcakDelegate>

@property (strong, nonatomic) DBEngraverAudioMicrophone *microphone;

// 读取文件的指针
@property (assign, nonatomic) FILE *micPCMFile;

@property (nonatomic,strong) dispatch_source_t timer;

@property(nonatomic,copy)NSString * queryId;

@property(nonatomic,strong)DBEngraverNetworkHelper * networkHelper;

/// 复刻的文本
@property(nonatomic,strong)NSMutableArray<DBTextModel *> * textModelArray;

// 每段复刻声音的sessionId
@property(nonatomic,copy)NSString * sessionId;

@property (nonatomic,strong) DBZSocketRocketUtility * socketManager;

@property (nonatomic,strong) NSMutableArray * fileNameArr;

@property(nonatomic,weak)id<DBParamsDelegate>  paramsDelegate;

@property (nonatomic,strong) NSMutableDictionary * socketDic;

// 0:初始化未连接，1连接中， 2连接结束
@property (nonatomic,assign) int socketStatus;

/// socket音频的序列
@property (nonatomic,assign) NSInteger socketSequence;

// 标记socket的最后一frame，Yes:最后一帧，NO:不是最后一帧
@property (nonatomic,assign) BOOL issocketStatusEnd;

/// PCM数据，存放PCM文件的路径
@property (nonatomic, copy) NSString * PCMFilePath;
@property(nonatomic,copy)DBVoiceRecogizeHandler  voiceHandler;
/// 试听播放器
@property (nonatomic, strong) DBRecordPCMDataPlayer * pcmDataPlayer;
/// 当前录制到第几条
@property (nonatomic, assign,readwrite) NSInteger currentRecordIndex;
/// 当前复刻的类型
@property (nonatomic,assign) DBReprintType reprintType;
@property (nonatomic, copy,readwrite) NSString * accessToken;
@end

@implementation DBVoiceEngraverManager

+ (instancetype )sharedInstance {
    static DBVoiceEngraverManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
        [sharedInstance initParams];
    });
    return sharedInstance;
}

- (void)initParams {
    self.microphone = [[DBEngraverAudioMicrophone alloc] initWithSampleRate:16000 numerOfChannel:1];
    self.microphone.delegate = self;
    self.networkHelper = [[DBEngraverNetworkHelper alloc]init];
    self.networkHelper.delegate = self;
    self.paramsDelegate = self.networkHelper;
    [self.paramsDelegate clearAudioFile];
    self.enableLog = NO;
    self.currentRecordIndex = 0;
    self.socketStatus = 0;
    self.socketSequence = 0;
    self.issocketStatusEnd = NO;
    self.PCMFilePath =  [self.paramsDelegate makeFile];
}

- (void)resetParams {
    self.currentRecordIndex = 0;
    self.socketStatus = 0;
    self.socketSequence = 0;
    self.issocketStatusEnd = NO;
    [self.paramsDelegate clearAudioFile];
    self.PCMFilePath =  [self.paramsDelegate makeFile];
    [self.socketDic removeAllObjects];
    self.sessionId = nil;
    self.textModelArray = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: Network Methods -

// MARK: 初始化SDK
- (void)setupWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret queryId:(nullable NSString *)queryId rePrintType:(DBReprintType)reprintType successHandler:(nonnull DBMessageHandler)successHandler failureHander:(nonnull DBFailureHandler)failureHandler {
    NSAssert(successHandler, @"请设置DBSuccessHandler的回调");
    NSAssert(failureHandler, @"请设置DBFailureHandler的回调");
    NSError *error;
    if (!clientId) {
        error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateInitlizeSDK userInfo:@{@"msg":@"clientId error"}];
        failureHandler(error);
        return ;
    }
    if (!clientSecret) {
        error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateInitlizeSDK userInfo:@{@"msg":@"client secret error"}];
        failureHandler(error);
        return ;
    }
    self.reprintType = reprintType;
    self.queryId = queryId;
    // 给网络请求设置clientId
    self.networkHelper.clientId = clientId;
    self.networkHelper.clientSecret = clientSecret;
    [DBAuthentication setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
        if(error) {
            failureHandler(error);
            return;
        }
        if(!token) {
            NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateFailureToAccessToken userInfo:@{@"userInfo":@"获取token失败"}];
            failureHandler(error);
        }
        self.networkHelper.token = token;
        self.accessToken = token;
        successHandler(@"");
    }];
}

// MARK: 设置queryID
- (void)setupQueryId:(NSString *)queryId {
    self.queryId = queryId;
}

// MARK: ------------------------ 发起网络请求 -----------------------------
- (void)getNoiseLimit:(DBMessageHandler)handler failuer:(DBFailureHandler)failureHandler {
    NSAssert2(handler&&failureHandler, @"Handler can't be nil", handler, failureHandler);
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBURLConfigQuery) parameters:@{} success:^(NSDictionary * _Nullable dict) {
        NSString *noise = dict[@"environmentalNoiseDetectionThreshold"];
        if(IsEmpty(noise)) { // 默认限为60
            handler(@"60");
            return;
        }
        handler(noise);
    } failure:failureHandler];
}


// MARK: 第一次录制，开启一个sessionId
- (void)startRecordWithSessionId:(NSString *)sessionId textIndex:(NSInteger)textIndex messageHandler:(DBMessageHandler)messageHandler failureHander:(DBFailureHandler)failureHandler {
    NSAssert2(failureHandler&&messageHandler, @"请设置messageHandler:%@,failureHandler:%@", messageHandler, failureHandler);
    if (textIndex > self.textModelArray.count -1) {
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateNetworkDataError userInfo:@{@"info":@"textIndex超过了数组的上界"}];
        failureHandler(error);
        return;
    }
    self.currentRecordIndex = textIndex;
    [self startSocket];
}


// MARK: 上传声音识别
- (void)uploadRecordVoiceRecogizeHandler:(DBVoiceRecogizeHandler)successHandler  {
    self.issocketStatusEnd = YES;
    self.voiceHandler = successHandler;
}

// MARK: 获取sessionId
- (void)networkGetSessionId:(NSString *)sessionId
                    success:(DBTextModelArrayHandler)succeessBlock
               failureBlock:(DBFailureHandler)failureBlock {
    NSAssert(succeessBlock, @"请设置DBSuccessHandler回调");
    NSAssert(failureBlock, @"请设置DBFailureHandler的回调");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!IsEmpty(self.queryId)) {
        params[@"queryId"] = self.queryId;
    }
    if (!IsEmpty(sessionId)) {
        params[@"sessionId"] = sessionId;
    }
    params[@"modelType"] = @(self.reprintType).stringValue;
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBURLStartSession) parameters:params success:^(NSDictionary * _Nonnull data) {
        if ([data isEqual:[NSNull null]]) {
            NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateFailureToGetSession userInfo:nil];
            failureBlock(error);
            return ;
        }
        NSString *sessionId = data[@"data"][@"sessionId"];
        self.sessionId = sessionId;
        
        NSArray *sentenceList = data[@"data"][@"sentenceList"];
        NSMutableArray *sentenceModelList = [NSMutableArray array];
        for (NSDictionary *sentenceDic in sentenceList) {
            DBTextModel *model = [[DBTextModel alloc]init];
            [model setValuesForKeysWithDictionary:sentenceDic];
            [sentenceModelList addObject:model];
        }
        succeessBlock(sentenceList.count,sentenceModelList,sessionId);
    } failure:^(NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

// MARK: 根据modelId查询模型状态
- (void)queryModelStatusByModelId:(NSString *)modelId SuccessHandler:(DBSuccessOneModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler {
    NSAssert(successHandler, @"请设置DBSuccessOneModelHandler的回调");
    NSAssert(failureHandler, @"请设置DBFailureHandler的回调");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (modelId) {
        params[@"modelId"] = modelId;
    }
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBQueryModelStatus) parameters:params success:^(NSDictionary * _Nonnull data) {
        if ([data isEqual:[NSNull null]]) {
            NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateNetworkDataError userInfo:nil];
            failureHandler(error);
            return ;
        }
        NSDictionary *dict = data[@"data"];
        DBVoiceModel *model = [[DBVoiceModel alloc]init];
        [model setValuesForKeysWithDictionary:dict];
        successHandler(model);
    } failure:^(NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

//MARK: 根据queryId 批量查询模型状态
- (void)batchQueryModelStatusByQueryId:(NSString *)queryId SuccessHandler:(DBSuccessModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler {
    
    NSAssert(successHandler, @"请设置DBSuccessModelHandler的回调");
    NSAssert(failureHandler, @"请设置failureHandler的回调");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.queryId) {
        params[@"queryId"] = self.queryId;
    }
    if (queryId) {
        params[@"queryId"] = queryId;
    }
    
    params[@"limit"] = @(100);
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBQueryModelStatusBatch) parameters:params success:^(NSDictionary * _Nonnull data) {
        /// 异常处理
        if ([data isEqual:[NSNull null]]) {
            NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateFailureToGetSession userInfo:nil];
            failureHandler(error);
            return ;
        }
        NSArray *array = data[@"data"][@"list"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            DBVoiceModel *model = [[DBVoiceModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [tempArray addObject:model];
        }
        successHandler(tempArray);
    } failure:^(NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

// MARK: public 通过SessionID开启一个新的会话
- (void)getTextArrayWithSeesionId:(NSString *)sessionId textHandler:(DBTextModelArrayHandler)textHandler failure:(DBFailureHandler)failureHandler {
    NSAssert2(textHandler&&failureHandler, @"请设置textHanlder:%@,failureHandler:%@", textHandler, failureHandler);
    [self networkGetSessionId:sessionId success:^(NSInteger index, NSArray<DBTextModel *> * _Nonnull array,NSString *sessionId) {
        self.textModelArray = [NSMutableArray array];
        self.sessionId = sessionId;
        
        __block NSInteger p_index = 0;
        [array enumerateObjectsUsingBlock:^(DBTextModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DBTextModel *model = [[DBTextModel alloc]init];
            model.text = obj.text;
            if(!IsEmpty(obj.audioUrl)) {
                p_index++;
                model.passStatus = @1;
            }else {
                model.passStatus = @0;
            }
            model.audioUrl = obj.audioUrl;
            model.index = idx;
            [self.textModelArray addObject:model];
        }];
        textHandler(p_index,array,sessionId);
    } failureBlock:failureHandler];
    
}




//MARK:  获取声音限制
//- (void)getRecordLimitSuccessHandler:(DBSuccessHandler)successHandler failureHander:(DBFailureHandler)failureHandler {
//    NSAssert(successHandler, @"请设置DBSuccessHandler的回调");
//    NSAssert(failureHandler, @"请设置DBFailureHandler的回调");
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBURLVoliceLimit) parameters:params success:^(NSDictionary * _Nonnull data) {
//        successHandler(data);
//    } failure:^(NSError * _Nonnull error) {
//        failureHandler(error);
//    }];
//}

// MARK: 开始录音
- (void)startRecord {
    if (self.textModelArray.count-1 < self.currentRecordIndex) {
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateFailureInvalidParams userInfo:@{@"info":@"音频文本为空"}];
        [self delegateError:error];
        return;
    }
    [self recordAddTimer];

    NSString * filePath = [self filePathWithIndex:self.currentRecordIndex];
    DBTextModel *model = self.textModelArray[self.currentRecordIndex];
    model.filePath = filePath;
    
    // TODO: 测试数据
//    [self testAudioData];
    NSLog(@"当前录制路径 ：%@",filePath);
    self.micPCMFile = fopen(filePath.UTF8String, "wb");
    if (self.microphone) {
        [self.microphone stop];
        self.microphone.delegate = nil;
    }
    self.microphone = [[DBEngraverAudioMicrophone alloc] initWithSampleRate:16000 numerOfChannel:1];
      self.microphone.delegate = self;
    [self.microphone start];
}



// TODO: TEST AudioData
- (void)testAudioData {
    [self.textModelArray enumerateObjectsUsingBlock:^(DBTextModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"obj %@",obj);
    }];
}

// MARK: 主动结束录音
- (void)unNormalStopRecordSeesionSuccessHandler:(DBMessageHandler)successBlock failureHandler:(DBFailureHandler)failureHandler {
    [self pauseRecord];
    if (!self.sessionId) { // 如果未开启session,直接回调
        successBlock(@"115001"); // 不存在session Id的相关信息
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateEmptySessionId userInfo:@{@"message":@"传入的SessionId不能为空"}];
        failureHandler(error);
        return;
    }
    NSAssert(successBlock, @"请设置DBSuccessHandler回调");
    NSAssert(failureHandler, @"请设置DBFailureHandler回调");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = self.sessionId;
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBURLStopSession) parameters:params success:^(NSDictionary * _Nonnull data) {
        self.sessionId = nil;
        successBlock(@"0");
    } failure:^(NSError * _Nonnull error) {
        failureHandler(error);
    }];
}


// MARK: 试听
- (void)listenAudioWithTextIndex:(NSInteger)index {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    DBTextModel *model = self.textModelArray[index];
    NSData *data;
    if (!IsEmpty(model.filePath)) {
        NSString *filePath = model.filePath;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (!exist) {
            NSLog(@"No file Exsits");
            return;
        }
       data = [[NSData alloc] initWithContentsOfFile:filePath];
    }else if(!IsEmpty(model.audioUrl)) {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.audioUrl]];
    }else {
        NSLog(@"No Audio Data");
        return;
    }
    if (!self.pcmDataPlayer) {
        self.pcmDataPlayer = [[DBRecordPCMDataPlayer alloc]init];
        self.pcmDataPlayer.delegate = self;
    }
    [self.pcmDataPlayer stop];
    [self.pcmDataPlayer play:data];
}

- (void)stopCurrentListen {
    [self.pcmDataPlayer stop];
}


// MARK: 开启模型训练
- (void)startModelTrainRecordVoiceWithPhoneNumber:(NSString *)phoneNumber notifyUrl:(NSString *)notifyUrl successHandler:(DBSuccessOneModelHandler)successHandler failureHander:(DBFailureHandler)failureHandler {
    NSAssert(successHandler, @"请设置DBSuccessOneModelHandler的回调");
    NSAssert(failureHandler, @"请设置DBFailureHandler的回调");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sessionId"] = self.sessionId;
    if (phoneNumber) {
        params[@"mobilePhone"] = phoneNumber;
    }
    if (notifyUrl) {
        params[@"notifyUrl"] = notifyUrl;
    }
    [self.networkHelper postWithUrlString:join_string1(KDB_BASE_PATH, DBuploadInformation) parameters:params success:^(NSDictionary * _Nonnull data) {
        /// 异常处理
        if ([data isEqual:[NSNull null]] ) {
            NSError *error = [NSError errorWithDomain:DBErrorDomain code:DBErrorStateNetworkDataError userInfo:nil];
            failureHandler(error);
            return ;
        }
        
        NSString *modelId;
        if (self.sessionId.length > 36) {
            modelId = [self.sessionId substringToIndex:36];
        }
        [self resetParams];
        DBVoiceModel *model = [[DBVoiceModel alloc]init];
        model.modelId = modelId;
        successHandler(model);
    } failure:^(NSError * _Nonnull error) {
        failureHandler(error);
    }];
}

// MARK: 进入下一条
- (BOOL)canNextStepByCurrentIndex:(NSInteger)currentIndex {
    __block  NSInteger recordedMaxIndex = 0;
    [self.textModelArray enumerateObjectsUsingBlock:^(DBTextModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.passStatus integerValue] == 1) {
            recordedMaxIndex = MAX(obj.index, recordedMaxIndex)+1;
        }
    }];
    if (currentIndex < recordedMaxIndex) {
        return YES;
    }else {
        return NO;
    }
}
// MARK: 停止录音
- (void)pauseRecord {
    [self recordCancelTimer];
    [self.microphone pause];
    fclose(self.micPCMFile);
}

- (void)recordCancelTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
}
- (void)recordAddTimer {
    __block NSInteger timeout = 60*2; //倒计时时间
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    _timer = timer;
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self pauseRecord];
                NSLog(@"录音时长超过限制2Min");
            });
        }else{
            timeout--;
        }
    });
    dispatch_resume(timer);
}

// MARK: DBAudioMicrophoneDelegate methods


- (void)audioMicrophone:(DBEngraverAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize  {
    NSLog(@"内置mic 数据长度: %u", byteSize);
    fwrite(pcmByte, 1, byteSize, self.micPCMFile);
    NSData*data = [[NSData alloc]initWithBytes:pcmByte length:byteSize];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    NSString *audioString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    self.socketDic[@"info"] = audioString;
    if (self.issocketStatusEnd) {
        self.issocketStatusEnd = NO;
        [self pauseRecord];
        self.socketStatus = 2;
        self.socketDic[@"status"] = @(self.socketStatus);
        NSLog(@"开始传输最后一帧数据%@",self.socketDic[@"status"]);
        [self.socketManager sendData:[self jsonData:self.socketDic isEncodedString:NO]];
        NSLog(@"socketDict:%@",self.socketDic);
        return;
    }
    if (self.socketStatus == 2) {
        NSLog(@"传输数据结束");
        return;
    }
    NSLog(@"开始传输数据%@",self.socketDic[@"status"]);
    NSLog(@"数据序号%@",self.socketDic[@"sequence"]);
    NSLog(@"socketDict:%@",self.socketDic);
    [self.socketManager sendData:[self jsonData:self.socketDic isEncodedString:NO]];
    self.socketStatus = 1;
    self.socketSequence++;
    self.socketDic[@"status"] = @(self.socketStatus);
    self.socketDic[@"sequence"] = @(self.socketSequence);
}

- (void)audioCallBackVoiceGrade:(NSInteger)grade {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(dbDetecting:)]) {
            [self.delegate dbDetecting:grade];
        }
    });
}

- (void)audioMicrophonInterrupted {
    if(self.delegate && [self.delegate respondsToSelector:@selector(dbAudioInterrupted)]) {
        [self.delegate dbAudioInterrupted];
    }
}

// MARK: 播放完成回调
- (void)PCMPlayerDidFinishPlaying{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playToEnd)]) {
        [self.delegate playToEnd];
    }
}
// MARK: 请求数据的代理
- (void)updateTokenSuccessHandler:(nonnull DBMessageHandler)successHandler failureHander:(nonnull DBFailureHandler)failureHandler {
    [self setupWithClientId:self.networkHelper.clientId clientSecret:self.networkHelper.clientSecret queryId:self.queryId rePrintType:self.reprintType successHandler:successHandler failureHander:failureHandler];
}

// MARK: websocket的相关方法 --
- (void)startSocket {
    // 在调用start之前，先关闭掉之前的socket;
    [self stopSocket];
    // 超时时间为10秒
    self.socketManager.timeOut = 6;
    NSDictionary *dict =  [self.paramsDelegate paramasDelegateRequestParamas];
    NSLog(@"dict :%@",dict);
    NSString * url = [NSString stringWithFormat:@"%@?data=%@",KDB_WEBSOCKET_URL,[self  headerParams:dict jsonData:nil isEncodedString:YES]];
    NSLog(@"开始建立连接url %@",url);
    [self.socketManager DBZWebSocketOpenWithURLString:url];
}

- (void)stopSocket {
    [self.socketManager DBZWebSocketClose];
}
- (void)webSocketDidOpenNote {
    [self.paramsDelegate logMessage:@"scoket连接成功 self %@",self];
}
- (void)webSocketdidReceiveMessageNote:(id)note {
    NSLog(@"note:%@",note);
    NSString *message = (NSString *)note;
    NSDictionary * dic =[NSMutableDictionary dictionaryWithDictionary:[self.paramsDelegate dictionaryWithJsonString:message]];
    NSInteger code = [dic[@"code"] integerValue];
    if (code == 11 || code == 00011) { // token 失效
        [self updateTokenSuccessHandler:^(NSString * _Nonnull message) {
        } failureHander:^(NSError * _Nonnull error) {
        }];
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:code userInfo:@{@"message":@"token失效，请重试"}];
        [self delegateError:error];
        return ;
    }
    
    if (code != 20000) {
        [self resetSocketState];

        [self.paramsDelegate logMessage:@"返回结果出错"];
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:code userInfo:@{@"message":dic[@"message"]}];
        [self delegateError:error];
        return ;
    }
    
    if ([dic[@"data"] isEqual:[NSNull null]]) {
        [self resetSocketState];
        [self.paramsDelegate logMessage:@"返回结果出错"];
        NSError *error = [NSError errorWithDomain:DBErrorDomain code:20001 userInfo:@{@"errorInfo":@"返回结果为空"}];
        [self delegateError:error];
        return;
    }
    
    if ([dic[@"data"][@"type"] integerValue] == 0) {
        
        self.socketStatus = 0;
        self.socketSequence = 0;
        self.socketDic = dic[@"data"];
        self.socketDic[@"status"] = @(self.socketStatus);
        self.socketDic[@"sequence"] = @(self.socketSequence);
        NSLog(@"%@",self.fileNameArr);
        if (self.fileNameArr.count > self.currentRecordIndex) {
            [self.fileNameArr replaceObjectAtIndex:self.currentRecordIndex withObject:dic[@"data"][@"fileName"]];
        }else {
            [self.fileNameArr addObject:dic[@"data"][@"fileName"]];
        }
        NSLog(@"打开麦克风");
        [self startRecord];
        
    }else {
        [self resetSocketState];
        if ([dic[@"data"][@"passStatus"] integerValue] == 1) {
            DBTextModel *model = self.textModelArray[self.currentRecordIndex];
            [model setValuesForKeysWithDictionary:dic[@"data"]];
            self.voiceHandler(model);
        }else{
            [self.paramsDelegate logMessage:@"录音不合格"];
            DBTextModel *model = self.textModelArray[self.currentRecordIndex];
            [model setValuesForKeysWithDictionary:dic[@"data"]];
            self.voiceHandler(model);
        }
    }
}

- (void)resetSocketState {
    [self stopSocket];
    self.socketStatus = 0;
    self.socketSequence = 0;
}

- (void)webSocketDidCloseNote:(id)object {
    NSLog(@"socket 连接关闭");
}

- (void)webSocketdidConnectFailed:(id)noti {
    NSLog(@"%@",noti);
    NSError *error = [NSError errorWithDomain:DBErrorDomain code:20002 userInfo:@{@"errorInfo":@"服务器连接错误"}];
    [self delegateError:error];
}

- (NSString *)jsonData:(NSMutableDictionary *) socket isEncodedString:(BOOL)encodedString{
    NSDictionary *dict =  [self.paramsDelegate paramasDelegateRequestParamas];
   NSString * params = [self headerParams:dict jsonData:socket isEncodedString:encodedString];
    return params;
}

- (NSString *)headerParams:(NSDictionary *)params jsonData:(NSDictionary *)socket isEncodedString:(BOOL)encodedString {
    if (!socket) {
        socket = [[NSMutableDictionary alloc]init];
    }
    NSString * rerecordingFileName = @"";
    if (self.fileNameArr.count != 0) {
        if (self.fileNameArr.count  > self.currentRecordIndex) {
            rerecordingFileName = self.fileNameArr[self.currentRecordIndex];
        }
    }
    NSDictionary * dic = @{
        @"header": params ? params:@"",
        @"param": @{
                @"sessionId": self.sessionId,
                @"originText": [self currentText],
                @"rerecordingFileName":rerecordingFileName,
                @"index": @(self.currentRecordIndex)
        },
        @"audio": socket
    };
    
//    NSLog(@"request params :%@",dic);
    NSString * urlStr = [self.paramsDelegate dictionaryToJson:dic];
    NSString* encodedURL;
    if (encodedString) {
        NSCharacterSet *allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet;
        encodedURL =  [urlStr stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    }else {
        encodedURL = urlStr;
    }
    return encodedURL;
}

- (NSString *)currentText {
    DBTextModel *model = self.textModelArray[self.currentRecordIndex];
    return model.text;
}

- (void)delegateError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dbVoiceRecognizeError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dbVoiceRecognizeError:error];
        });
    }
}


// MARK: custom Accessors

-(NSString *)filePathWithIndex:(NSInteger)index {
    if ([self.PCMFilePath isEqualToString:@""]) {
        return @"";
    }
    NSString *fileName = [NSString stringWithFormat:@"%ld.pcm",index];
    NSString *filePath = [self.PCMFilePath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSError *)throwError:(DBErrorState)code message:(NSString *)msg {
    return throwError(DBErrorDomain, code, msg);
}



// MARK: Custom Accessor Methods

- (DBZSocketRocketUtility *)socketManager {
    if (!_socketManager) {
        _socketManager = [DBZSocketRocketUtility instance];
        _socketManager.delegate = self;
    }
    return _socketManager;
}

-(NSMutableArray *)fileNameArr {
    if (!_fileNameArr) {
        _fileNameArr = [[NSMutableArray alloc]init];
    }
    return _fileNameArr;
}

- (NSMutableDictionary *)socketDic {
    if (!_socketDic) {
        _socketDic = [NSMutableDictionary dictionary];
    }
    return _socketDic;
}

- (DBReprintType)currentType {
    return self.reprintType;
}

+(NSString *)sdkVersion {
    return KAUDIO_SDK_VERSION;
}

+ (NSString *)ttsIPURL {
    return ttsIPURL;
}



@end
