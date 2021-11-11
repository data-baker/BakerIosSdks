//
//  DBVPMatchReadVC.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import <UIKit/UIKit.h>
#import "DBVocalPrintClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBVPMatchReadVC : UIViewController
@property(nonatomic,strong)DBVocalPrintClient * vpClient;
@property(nonatomic,copy)NSNumber * threshold;
@property(nonatomic,copy)NSString * accessToken;
@end

NS_ASSUME_NONNULL_END
