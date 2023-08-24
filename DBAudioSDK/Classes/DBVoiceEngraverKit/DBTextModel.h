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
/// 音频链接
@property(nonatomic,copy)NSString * audioUrl;
/// 1:普通复刻； 2: 精品复刻
@property(nonatomic,assign)NSInteger type;

+ (instancetype)textModelWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
