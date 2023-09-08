//
//  DBRecordTextVC.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DBTextModel;
NS_ASSUME_NONNULL_BEGIN

@protocol DBSessionIdDelegate <NSObject>

- (NSString *)getCurrentSessionId;

- (void)setCurrentSessionId:(NSString *)sessionId;

- (void)removeCurrentSessionId;

@end

@interface DBRecordTextVC : UIViewController
@property(nonatomic,copy)NSArray <DBTextModel *>* textArray;
/// 表示当前录制的是第几条
@property (nonatomic, assign) NSInteger index;

@property(nonatomic,weak)id<DBSessionIdDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
