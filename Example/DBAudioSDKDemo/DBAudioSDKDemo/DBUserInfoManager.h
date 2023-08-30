//
//  DBUserInfoManager.h
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/8/5.
//

#import <Foundation/Foundation.h>

#ifndef KUserDefalut
#define KUserDefalut [NSUserDefaults standardUserDefaults]
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DBUserInfoManager : NSObject

@property(nonatomic,copy)NSString * clientId;
@property(nonatomic,copy)NSString * clientSecret;
@property(nonatomic,copy)NSString * sdkType;

+ (instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
