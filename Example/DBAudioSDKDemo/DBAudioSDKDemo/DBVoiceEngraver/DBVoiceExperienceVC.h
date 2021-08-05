//
//  DBVoiceExperienceVC.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBVoiceEngraverManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BBCompleteHandler)(BOOL ret, NSString * _Nullable msg);


@interface DBVoiceExperienceVC : UIViewController

/// 声音的modelId
@property(nonatomic,strong)DBVoiceModel * voiceModel;

@end

NS_ASSUME_NONNULL_END
