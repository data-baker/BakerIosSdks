//
//  DBSynthesizer.m
//  frmeworkDemo
//
//  Created by 李明辉 on 2020/8/24.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBSynthesizer.h"
#import "DBOnlineResponseModel.h"
//#import <DBCommon/DBZSocketRocketUtility.h>
#import "DBZSocketRocketUtility.h"
//#import <DBCommon/DBLogManager.h>
#import "DBLogManager.h"

NSString *const wssSockDBSocketRocketKitetURL = @"wss://openapi.data-baker.com/wss";
//NSString *const wssSockDBSocketRocketKitetURL = @"wss://openapi.data-baker.com/tts/wsapi";

@interface DBSynthesizer ()<DBZSocketCallBcakDelegate>

@property(nonatomic,strong)DBZSocketRocketUtility * socketManager;

@property(nonatomic,assign,getter=isSocketOpen)BOOL socketOpen;
//  socket连接的url
@property(nonatomic,copy)NSString * socketUrl;
@end

@implementation DBSynthesizer

-(instancetype)init {
    if (self = [super init]) {
        [self logMessage:@"初始化合成器"];
        self.socketManager.delegate = self;
        self.socketOpen = NO;
    }
    return self;
}

- (void)setupPrivateDeploymentURL:(NSString *)url {
    self.socketUrl = url;
}

// MARK: 合成控制

- (void)start {
    // 在调用start之前，先关闭掉之前的socket;
    if (self.timeOut <= 0) {
        self.timeOut = 15;
    }
    [self stop];
    self.socketManager.timeOut = self.timeOut;
    if (self.socketUrl) {
        [self.socketManager DBZWebSocketOpenWithURLString:self.socketUrl];
    }else {
        [self.socketManager DBZWebSocketOpenWithURLString:wssSockDBSocketRocketKitetURL];
    }
    [self logMessage:@"合成器开始链接后台"];
}

- (void)stop {
    [self logMessage:@"合成器终止合成"];
    self.socketOpen = NO;
    [self.socketManager DBZWebSocketClose];
}

- (void)delegateOnfailureModel:(DBFailureModel *)failureModel {
    [self logMessage:[NSString stringWithFormat:@"%@",failureModel.message]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTaskFailed:)]) {
            [self.delegate onTaskFailed:failureModel];
        }
    });
}

// MARK: 在线合成SDK的代理方法
// 链接成功
- (void)webSocketDidOpenNote {
    [self logMessage:@"合成器链接成功"];
    NSString *jsonString = [self dictionaryToJson:self.onlineSynthesizerParameters];
    [self.socketManager sendData:jsonString];
    [self logMessage:[NSString stringWithFormat:@"合成器向服务器发送数据 = %@",jsonString]];
    self.socketOpen = YES;
    if (_synthesizerIndex==0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSynthesisStarted)]) {
            [self.delegate onSynthesisStarted];
        }
    }
}
// 链接失败
- (void)webSocketdidConnectFailed:(id)object {
    DBFailureModel *model = [[DBFailureModel alloc]init];
    model.code = DBErrorFailedCodeSynthesis;
    model.message = @"合成器与服务器失败";
    [self delegateOnfailureModel:model];
}
// 服务器返回数据
- (void)webSocketdidReceiveMessageNote:(id)object {
    //收到服务端发送过来的消息
    NSString * message = object;
    NSDictionary *dict = [self dictionaryWithJsonString:message];
    if (dict == nil) {
        [self logMessage:@"收到服务端的返回的数据"];
        return;
    }
    DBFailureModel *model = [[DBFailureModel alloc]init];
    [model setValuesForKeysWithDictionary:dict];
    //非私有化部署，并且token失效这时需要去刷新token
    if (model.code == 30000 && !self.socketUrl) {
        [self logMessage:@"合成器合成过程中,token失效,尝试刷新token"];
        if (self.synthesizerDelegate && [self.synthesizerDelegate respondsToSelector:@selector(refreshToken:)]) {
            [self.synthesizerDelegate refreshToken:^(BOOL ret, NSString * _Nonnull message) {
                if (ret) {
                    self.onlineSynthesizerParameters[@"access_token"] = message;
                    [self start];
                    [self logMessage:@"合成器合成过程中,token失效,刷新token成功"];
                }else {
                    model.message = @"合成器合成过程中,token失效,刷新token失败";
                    [self delegateOnfailureModel:model];
                }
            }];
        }
        return ;
    }

    if (model.code != 90000) {
        // 合成出现错误
        [self delegateOnfailureModel:model];
        return;
    }
    // 处理服务端返回的数据
    NSDictionary *dataDict = dict[@"data"];
    DBOnlineResponseModel *resModel = [[DBOnlineResponseModel alloc]init];
    [resModel setValuesForKeysWithDictionary:dataDict];
    [self logMessage:[NSString stringWithFormat:@"合成器收到服务器发过来的数据 %@",resModel]];
    _synthesizerIndex++;
    
  
    // 首包返回
    if (_synthesizerIndex == 1) {
        [self logMessage:@"合成器返回第一帧数据"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPrepared)]) {
            [self.delegate onPrepared];
        }
    }
    // 回调播放数据
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBinaryReceivedData:audioType:interval:interval_x:endFlag:)]) {
        [self.delegate onBinaryReceivedData:resModel.convertAudioData audioType:resModel.audio_type interval:resModel.interval interval_x:resModel.interval_x endFlag:resModel.endFlag];
    }
    
    // 一段合成完成
    if (resModel.endFlag) {
        [self logMessage:@"合成器合成完成一段文本"];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSynthesisCompleted)]) {
            [self.delegate onSynthesisCompleted];
        }
    }
    
    
}
// 关闭链接
- (void)webSocketDidCloseNote:(id)object {
    [self logMessage:[NSString stringWithFormat:@"合成器服务器关闭连接 %@",object]];
    self.socketOpen = NO;
}

// 工具
// base64编码
-(NSString *)base64EncodeString:(NSString *)baseString {
    NSString *encodeString = [baseString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *data = [encodeString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodeString = [data base64EncodedStringWithOptions:0]; //编码
    return base64EncodeString;
}

- (NSString *)base64DencodeString:(NSString *)base64String
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    if (parseError != nil) {
        DBFailureModel *model = [[DBFailureModel alloc]init];
        model.code = DBErrorFailedCodeResultParse;
        model.message = @"合成器给服务器发送数据,json序列化错误";
        [self delegateOnfailureModel:model];
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err != nil){
        DBFailureModel *model = [[DBFailureModel alloc]init];
        model.code = DBErrorFailedCodeResultParse;
        model.message = @"合成器返回结果解析错误";
        [self delegateOnfailureModel:model];
        return nil;
    }
    return dic;
}
// MARK: 打印错误日志
- (void)logMessage:(id)message {
    if (self.islog) {
        [DBLogManager saveCriticalSDKRunData:message];
    }
}

// MARK: - custom Accessor -
- (DBZSocketRocketUtility *)socketManager {
    if (!_socketManager) {
        _socketManager = [DBZSocketRocketUtility instance];
    }
    return _socketManager;
}
- (NSMutableDictionary *)onlineSynthesizerParameters {
    if (!_onlineSynthesizerParameters) {
        _onlineSynthesizerParameters = [NSMutableDictionary dictionary];
    }
    return _onlineSynthesizerParameters;
}

@end
