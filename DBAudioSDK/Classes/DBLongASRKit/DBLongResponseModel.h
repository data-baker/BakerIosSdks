//
//  DBResponseModel.h
//  DBASRFramework
//
//  Created by linxi on 2020/1/15.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


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
@property(nonatomic,copy)NSString * end_flag
;


@end

NS_ASSUME_NONNULL_END
