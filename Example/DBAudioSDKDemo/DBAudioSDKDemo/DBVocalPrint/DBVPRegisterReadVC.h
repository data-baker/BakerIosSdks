//
//  DBVPRegisterReadVC.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "DBVocalPrintClient.h"


NS_ASSUME_NONNULL_BEGIN

extern  NSString * const  userMatchId;
extern  NSString * const  matchId;
extern  NSString  * const  matchName;


@interface DBVPRegisterReadVC : UIViewController

@property(nonatomic,copy)NSString * name;
@property(nonatomic,copy)NSNumber * threshold;
@property(nonatomic,copy)NSString * accessToken;
@property(nonatomic,strong)DBVocalPrintClient * vpClient;

@end

NS_ASSUME_NONNULL_END
