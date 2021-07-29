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
@interface DBResponseModel : NSObject

/// 返回码
@property(nonatomic,assign)NSInteger code;

@property(nonatomic,copy)NSArray *nbest;

@property(nonatomic,copy)NSArray * uncertain;

@property(nonatomic,copy)NSString * trace_id;
/// 返回包的序号
@property(nonatomic,assign)NSInteger res_idx;

/// 最后一包，0不是最后一包
@property(nonatomic,assign)BOOL end_flag;

/// 错误描述
@property(nonatomic,copy)NSString * message;

/// ASR 带VAD解析后的数据
@property(nonatomic,copy)NSString *asr_text;


@end

NS_ASSUME_NONNULL_END
