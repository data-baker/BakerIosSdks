//
//  DBVoiceModel.h
//  DBVoiceEngraver
//
//  Created by linxi on 2020/3/10.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取声音模型的model
@interface DBVoiceModel : NSObject

@property(nonatomic,copy)NSString * modelId;
/*2：录制中 3：启动训练失败 4：训练中 5： 训练失败  6： 训练成功 */
@property(nonatomic,copy)NSNumber * modelStatus;
@property(nonatomic,copy)NSString * statusName;

@end


/// 声音识别的model
@interface DBVoiceRecognizeModel : NSObject

// 分数，90分以上可通过

@property(nonatomic,copy)NSNumber * percent;

// 通过结果 1:通过 0:未通过
@property(nonatomic,copy)NSNumber *  passStatus;

// Type: 0 第一次数据， 1：识别结束
@property(nonatomic,copy)NSNumber * type;


/// 标记当前录制的是第几条
@property(nonatomic,assign)NSInteger  index;

/// 当前录制的文本
@property(nonatomic,copy)NSString *recordText;

/// 当前录制音频的路径
@property(nonatomic,copy)NSString  * filePath;



@end

NS_ASSUME_NONNULL_END
