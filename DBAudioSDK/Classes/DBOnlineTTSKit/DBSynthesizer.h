//
//  DBSynthesizer.h
//  frmeworkDemo
//
//  Created by 李明辉 on 2020/8/24.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DBTTSEnumerate.h"
#import "DBFailureModel.h"
#import "DBSynthesizerManagerDelegate.h"
//#import <DBCommon/DBCommonConst.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DBMessageHandler)(BOOL ret,NSString * message);

@protocol DBSynthesizerDelegate <NSObject>

@required

/// 合成时鉴权失败重新鉴权
- (void)refreshToken:(DBMessageHandler)handler;



@end

@interface DBSynthesizer : NSObject

@property(nonatomic,weak)id <DBSynthesizerDelegate> synthesizerDelegate;

@property(nonatomic,weak)id <DBSynthesizerManagerDelegate> delegate;

///超时时间,默认15s
@property(nonatomic,assign)NSInteger  timeOut;

/// 在线合成的请求参数
@property(nonatomic,strong)NSMutableDictionary *onlineSynthesizerParameters;
/// 数据计数
@property(nonatomic,assign)NSInteger synthesizerIndex;
/// 1:打印日志 0：不打印日志,默认不打印日志
@property(nonatomic,assign,getter=islog)BOOL log;

// 针对私有化授权的服务使用，调用此方法后无需设置clientIf和clientSecret
- (void)setupPrivateDeploymentURL:(NSString *)url;
/// 开始合成
- (void)start;
///  停止合成
- (void)stop;

@end

NS_ASSUME_NONNULL_END
