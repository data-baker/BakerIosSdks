//
//  DBVoiceCopyEnumerte.h
//  DBVoiceCopyFramework
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//

#ifndef DBVoiceEngraverEnumerte_h
#define DBVoiceEngraverEnumerte_h

typedef NS_ENUM(NSUInteger,DBErrorState){
    DBErrorStateNOError                  = 0,// 成功，没有发生错误
    DBErrorStateMircrophoneNotPermission = 90000, // 麦克风没有权限
    DBErrorStateInitlizeSDK              = 900001, // 初始化SDK失败
    DBErrorStateFailureToAccessToken     = 900002, // 获取token失败
    DBErrorStateFailureToGetSession      = 900003, // 获取session失败
    DBErrorStateFailureInvalidParams      = 900004, // 无效的参数
    DBErrorStateNetworkDataError          = 99999,// 获取网络数据错误
    DBErrorStateTokenInvaild = 00011,// token失效
    DBErrorStateFailureErrorParams = 10003, // 参数错误
    DBErrorStateUploadFailed = 10004, // 上传文件失败，请选择正确的文件格式
    DBErrorStateEmptyfile = 10005, // 上传文件不能为空
    DBErrorStateModuleIdInvailid = 10008, // 模型Id不合法
    DBErrorStateModelSyns      = 10009 ,// 模型正在过程录制中，其他客户端不能同时录制！
    DBErrorStateRecognizeVoiceTimeOut = 10010, // 识别语音超时
    DBErrorStateMaxUploadTime = 40002 ,// 提交次数已达到最大限制
    DBErrorStateExpiredRquest = 40003, // 接口请在有效期内使用
    DBErrorStateRequestAuthFaild = 40004, // 接口签名不合法
    DBErrorStateInvaildMoile = 40005,// 请填写正确的手机号
    DBErrorStateEmptySessionId = 115001, // 传入的SessionId不能为空
    DBErrorStateParseFailed = 115002, // 解析网络数据失败
    
};



typedef void (^DBSuccessHandler)(NSDictionary *dict) __attribute__ ((deprecated("废弃（version >= 1.1.0）,使用`void (^DBMessageHandler)(NSString *msg)` 替代")));

// 回调信息
typedef void (^DBMessageHandler)(NSString *msg);


#endif /* DBVoiceCopyEnumerte_h */
