//
//  DBTextModel.h
//  DBAudioSDK
//
//  Created by 林喜 on 2023/8/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBTextModel : NSObject
/// 文本
@property(nonatomic,copy)NSString * text;

// 分数
@property(nonatomic,copy)NSNumber * percent;

// 通过结果 1:通过 0:未通过
@property(nonatomic,copy)NSNumber *  passStatus;

/// 标记当前录制的是第几条
@property(nonatomic,assign)NSInteger  index;

/// 当前录制音频的路径(本地路径)
@property(nonatomic,copy)NSString  * filePath;

// 播放使用的远程URL
@property(nonatomic,copy)NSString  * audioUrl;


+ (instancetype)textModelWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
