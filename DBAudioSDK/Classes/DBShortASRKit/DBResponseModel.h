//
//  DBResponseModel.h
//  DBASRFramework
//
//  Created by linxi on 2020/1/15.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WordsItem;
/// 返回的数据解析
@interface DBResponseModel : NSObject

/// 返回码
@property(nonatomic,assign)NSInteger code;
/// 错误描述
@property(nonatomic,copy)NSString * message;
// 任务id 用于定位错误跟踪日志
@property(nonatomic,copy)NSString * trace_id;

// 合并message和trace_id的信息
@property(nonatomic,copy)NSString * errorMsg;


// 识别结果，数组的形式表示
@property(nonatomic,copy)NSArray *nbest;
// 识别的中间文本
@property(nonatomic,copy)NSArray * uncertain;

/// 返回包的序号,数据块序列号，请求内容会以流式的数据块方式返回给客户端。服务器端生成，从1递增
@property(nonatomic,assign)NSInteger res_idx;

/// 最后一包，0不是最后一包
@property(nonatomic,assign)BOOL end_flag;

/// ASR 带VAD解析后的数据
@property(nonatomic,copy)NSString *asr_text;

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
@property (nonatomic , strong) NSArray <WordsItem *>              * bWords;

@end


 // 识别词组的相关消息
@interface WordsItem :NSObject
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
