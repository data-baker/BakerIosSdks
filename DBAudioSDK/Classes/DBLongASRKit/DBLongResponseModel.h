//
//  DBResponseModel.h
//  DBASRFramework
//
//  Created by linxi on 2020/1/15.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DBLWordsItem;

/// 返回的数据解析
@interface DBLongResponseModel : NSObject

/// 错误码4xxxx表示客户端参数错误，5xxxx表示服务端内部错误 90000标识成功
@property(nonatomic,assign)NSInteger code;
/// 识别结果 code为9000时包含有效数据
@property(nonatomic,copy)NSString *asr_text;
/// 错误描述
@property(nonatomic,copy)NSString * message;
/// 任务id
@property(nonatomic,copy)NSString * trace_id;
/// 一句话的最后一帧
@property(nonatomic,assign)BOOL sentence_end;
/// 句子id
@property(nonatomic,assign)NSInteger sentence_id;

/// 句子结束标识
@property(nonatomic,copy)NSString * end_flag;

/// 整句置信度[0-100]
@property (nonatomic , copy) NSString              * confidence;
/// 语速，取值[0-2000]
@property (nonatomic , assign) NSInteger              speed;
/*
 15以下：FAST 快
 15-30 : MEDIUM 适中
 30-2000：SLOW 慢
 */
@property (nonatomic , copy) NSString              * speed_label;
// 语音识别结果，失败时为空
@property (nonatomic , copy) NSString              * text;
/// 音量，取值[0-100]
@property (nonatomic , assign) NSInteger              volume;
/*
 音量标签：
 SILENT：0-15 静音
 XSOFT：15-30 音量很小
 SOFT：30-50 音量小
 MEDIUM：50-70 音量适中
 LOAD：70-85 音量大
 XLOUD：85-100 音量很大
 */
@property (nonatomic , copy) NSString              * volume_label;
/// 词级别识别结果
@property (nonatomic , strong) NSArray <DBLWordsItem *>              * bWords;

@end

// 识别词组的相关消息
@interface DBLWordsItem :NSObject
// 词置信度，置信度取值[0-100]
@property (nonatomic , copy) NSString              * confidence;
//  词在音频中的绝对开始时间点 单位：秒
@property (nonatomic , copy) NSString              * eos;
// 词在音频中的绝对结束时间点 单位：秒
@property (nonatomic , copy) NSString              * sos;
// 词
@property (nonatomic , copy) NSString              * word;

@end

NS_ASSUME_NONNULL_END
