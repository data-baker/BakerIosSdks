//
//  DBNetworkHelper.h
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBParamsDelegate.h"



NS_ASSUME_NONNULL_BEGIN

typedef void (^DBFailureHandler)(NSError *error);

typedef void (^DBSuccessHandler)(NSDictionary * __nullable dict);

/// 获取tokentypedef void (^DBFailureHandler)(NSError *error);



/// 文件上传
static NSString *const DBURLUploadFile = @"/user/record/result/check";
/// 获取录音文本接口
static NSString *const DBURLRecordTextList = @"/record/context/list";
/// 上传录音，识别获取准确率
static NSString *const DBURLrecordRessultCheck = @"/user/record/result/check";
/// 开始录音前获取session
static NSString *const DBURLStartSession = @"/user/record/start/session";
/// 非正常结束录制
static NSString *const DBURLStopSession = @"/user/record/stop/session";
/// 获取用户还剩几个声音权限
static NSString *const DBURLVoliceLimit = @"/user/record/voice/limit";
/// 上传模型的头像名称等信息
static NSString *const DBuploadInformation = @"/user/record/upload/information";
/// 查询模型状态
static NSString *const DBQueryModelStatus = @"/user/record/model/status";
/// 批量查询模型状态
static NSString *const DBQueryModelStatusBatch = @"/user/record/model/status/batch";


static NSString *const getTokenURL = @"https://openapi.data-baker.com/oauth/2.0/token";

//NSString *const getTokenURL = @"http://192.168.1.23:8083/oauth_new/oauth/2.0/token";


//开发
//NSString *const DBBaseURL = @"http://192.168.1.100:9403/gramophone/v2";

// 沙盒
//NSString *const DBBaseURL = @"https://gramophonetest.data-baker.com:9050/gramophone/v2";

// 生产
static NSString *const DBBaseURL = @"https://gramophone.data-baker.com/gramophone/v2";



//NSString * const DBSocketURL = @"wss://gramophonetest.data-baker.com:9050/gramophone/v2";


//NSString * const DBSocketURL = @"ws://192.168.1.100:9403/gramophone/websocket/v2";


// 沙盒
//NSString * const DBSocketURL = @"wss://gramophonetest.data-baker.com:9050/gramophone/websocket/v2";

// 生产

static NSString * const DBSocketURL = @"wss://gramophone.data-baker.com/gramophone/websocket/v2";


//https://gramophonetest.data-baker.com:9050/gramophone/

//NSString * const DBSocketURL = @"wss://asr.data-baker.com";


//NSString *const DBBaseURL = @"http://192.168.1.23:9403/v2";

#define join_string1(str1 ,str2) [NSString stringWithFormat:@"%@%@",str1, str2]

static NSString *const DBErrorDomain = @"DBVoiceEngraverErrorDomain";

@protocol DBUpdateTokenDelegate <NSObject>

- (void)updateTokenSuccessHandler:(nonnull DBSuccessHandler)successHandler failureHander:(nonnull DBFailureHandler)failureHandler;

@end

@interface DBEngraverNetworkHelper : NSObject<DBParamsDelegate>
/// 请求接口的toekn
@property(nonatomic,copy)NSString * token;

@property(nonatomic,copy)NSString * clientId;

// Yes，允许打日志，NO不允许打日志
@property(nonatomic,assign)BOOL  enableLog;

/// 刷新token的代理
@property(nonatomic,weak) id <DBUpdateTokenDelegate>  delegate;


/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;

/**
 * post请求
 */
- (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;


/// multipart上传表单数据
- (void)uploadWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;



@end

NS_ASSUME_NONNULL_END
