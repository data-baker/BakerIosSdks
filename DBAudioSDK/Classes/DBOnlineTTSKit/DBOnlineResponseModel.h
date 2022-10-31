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

/// 时间间隔，音子边界信息
@property(nonatomic,copy)NSString * interval;

/// 转化audio_data之后的值
@property(nonatomic,strong)NSData * convertAudioData;

/// 转化idx之后的值
@property(nonatomic,assign)NSInteger index;

/// 结束标志
@property(nonatomic,assign)BOOL endFlag;

/*
 interval-info-x: L=1&T=1,L=1&T=2,L=1&T=1,L=1&T=2,L=1&T=5
 L表示语言种类，目前支持1：纯中文，5：中英混
 T表示interval类型，0：默认值，1：声母，2：韵母，3：儿化韵母，4：英文，5：#3静音
 */
@property(nonatomic,copy)NSString * interval_x;


@end

NS_ASSUME_NONNULL_END
