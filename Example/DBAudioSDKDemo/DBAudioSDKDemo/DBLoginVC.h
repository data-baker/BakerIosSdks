//
//  DBLoginVC.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/12.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBUserInfoManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBLoginVC : UIViewController

@property(nonatomic,copy)dispatch_block_t handler;
@property(nonatomic,copy)NSString * sdkName; // 当前的标题

@end

NS_ASSUME_NONNULL_END
