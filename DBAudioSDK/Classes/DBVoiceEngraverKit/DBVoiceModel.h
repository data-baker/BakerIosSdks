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
//模型状态中文(值)
@property(nonatomic,copy)NSString * statusName;
/// 1: 普通复刻 2:精品复刻
@property(nonatomic,copy)NSString * type;

@end




NS_ASSUME_NONNULL_END
