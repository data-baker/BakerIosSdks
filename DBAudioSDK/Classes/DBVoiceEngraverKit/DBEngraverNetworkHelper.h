//
//  DBNetworkHelper.h
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBParamsDelegate.h"
#import "DBVoiceEngraverEnumerte.h"


// MARK: 此处的开关定义在'DBAuthentication' 类中
#if DBRelease
//#define KBASE_HOST @"http://10.10.20.107:9922"
//#define KBASE_HOST_WEBSOCKET @"wss://10.10.20.107:9922"
#define KBASE_HOST @"https://openapi.data-baker.com"
#define KBASE_HOST_WEBSOCKET @"ws://10.10.20.107:9922"
#else
#define KBASE_HOST @"http://10.10.20.107:9922"
#define KBASE_HOST_WEBSOCKET @"ws://10.10.20.107:9922"
#endif
#define KREPRINT_PATH  @"/gramophone/v3"
#define join_string1(str1 ,str2) [NSString stringWithFormat:@"%@%@",str1, str2]
#define KDB_BASE_PATH join_string1(KBASE_HOST,KREPRINT_PATH)
#define KDB_WEBSOCKET_URL  join_string1(KBASE_HOST_WEBSOCKET,@"/gramophone/websocket/fuke/v3")

NS_ASSUME_NONNULL_BEGIN
typedef void (^DBFailureHandler)(NSError *error);
typedef void (^DBNSuccessHandler)(NSDictionary * __nullable dict);
/// 文件上传
static NSString *const DBURLUploadFile = @"/user/record/result/check";
/// 获取录音文本接口
static NSString *const DBURLRecordTextList = @"/record/context/list";
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

static NSString *const DBErrorDomain = @"DBVoiceEngraverErrorDomain";

@protocol DBUpdateTokenDelegate <NSObject>

- (void)updateTokenSuccessHandler:(nonnull DBMessageHandler)successHandler failureHander:(nonnull DBFailureHandler)failureHandler;

@end

@interface DBEngraverNetworkHelper : NSObject<DBParamsDelegate>
/// 请求接口的toekn
@property(nonatomic,copy)NSString * token;

@property(nonatomic,copy)NSString * clientId;
@property(nonatomic,copy)NSString * clientSecret;

// Yes，允许打日志，NO不允许打日志
@property(nonatomic,assign)BOOL  enableLog;

/// 刷新token的代理
@property(nonatomic,weak) id <DBUpdateTokenDelegate>  delegate;

/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(DBNSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;

/**
 * post请求
 */
- (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(DBNSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;


/// multipart上传表单数据
- (void)uploadWithUrlString:(NSString *)url parameters:(id)parameters success:(DBNSuccessHandler)successBlock failure:(DBFailureHandler)failureBlock;



@end

NS_ASSUME_NONNULL_END
