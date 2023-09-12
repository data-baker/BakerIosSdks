//
//  DBTimeLogerUtil.h
//  DBEvaluateDemo
//
//  Created by 林喜 on 2022/12/30.
//

#import <Foundation/Foundation.h>

#define KTimeUtil [DBTimeLogerUtil shareInstance]

NS_ASSUME_NONNULL_BEGIN

@interface DBTimeLogerUtil : NSObject

+ (instancetype)shareInstance;

// yes： 已经计时， no: 还没有计时
@property(nonatomic,assign)BOOL logFlag;
@property(nonatomic,assign)BOOL isComplete;
@property(nonatomic,assign)BOOL isLogTime;

/// 设置合成的文本
- (void)logerStartTimeWithSynthesisText:(NSString *)text;

- (void)logerConnectTime;


/// 记录合成的厂商，识别的时候调用该方法
/// - Parameter vendor: 厂商
- (void)logerASRStartTimeWithVendor:(NSString *)vendor;

// 记录asr的文本
- (void)logerAsRText:(NSString *)text;

// 获取ASR总体的时间
- (CFTimeInterval)getAsrTotalTime;



// 记录包的返回时间
- (void)logerPackageTime;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


- (void)logTransferStart;
// 设置记录完成
- (void)setTimeComplete;

@end

NS_ASSUME_NONNULL_END
