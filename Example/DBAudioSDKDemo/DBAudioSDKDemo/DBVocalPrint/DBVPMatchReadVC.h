//
//  DBVPMatchReadVC.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBVPMatchReadVC : UIViewController
@property(nonatomic,copy)NSNumber * threshold;
@property(nonatomic,copy)NSString * accessToken;
@property(nonatomic,copy)NSString * matchId;
@property(nonatomic,copy)NSString * matchName;

/// yes: 1:N 匹配 No: 1:1 匹配， 默认使用1:1 匹配
@property(nonatomic,assign)BOOL  isMatchMore;

@end

NS_ASSUME_NONNULL_END
