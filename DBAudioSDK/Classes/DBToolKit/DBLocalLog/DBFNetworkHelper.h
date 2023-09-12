//
//  DBNetworkHelper.h
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DBEnmerator.h"

NS_ASSUME_NONNULL_BEGIN


@interface DBFNetworkHelper : NSObject

/// 上传日志统计的信息
+ (void)uploadLevel:(DBLogLevel)level userMsg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
