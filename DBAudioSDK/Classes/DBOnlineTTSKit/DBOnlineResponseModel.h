//
//  DBOnlineModel.h
//  DBTTSScocketSDK
//
//  Created by linxi on 2019/11/21.
//  Copyright © 2019 newbike. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBOnlineResponseModel : NSObject

/// online返回的audio data
@property(nonatomic,copy)NSString * audio_data;

/// 音频类型
@property(nonatomic,copy)NSString * audio_type;

/// 结束标志
@property(nonatomic,copy)NSString * end_flag;

/// 数据包的index
@property(nonatomic,copy)NSString * idx;

/// 时间间隔
@property(nonatomic,copy)NSString * interval;

/// 转化audio_data之后的值
@property(nonatomic,strong)NSData * convertAudioData;

/// 转化idx之后的值
@property(nonatomic,assign)NSInteger index;

/// 结束标志
@property(nonatomic,assign)BOOL endFlag;

@end

NS_ASSUME_NONNULL_END
