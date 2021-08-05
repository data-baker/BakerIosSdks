//
//  DBVoiceDetectionUtil.h
//  DBVoiceEngraver
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBVoiceEngraverEnumerte.h"
#import "DBVoiceDetectionDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface DBVoiceDetectionUtil : NSObject


@property(nonatomic,weak)id<DBVoiceDetectionDelegate>  delegate;

// 检测声音
-(DBErrorState)startDBDetection;

@end

NS_ASSUME_NONNULL_END
