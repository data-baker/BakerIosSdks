//
//  DBLogerModel.h
//  DBCrashLogKit
//
//  Created by biaobei on 2022/4/27.
//

//声明单例
#undef    DECLARE_SINGLETON
#define DECLARE_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;

//定义单例
#undef    DEFINE_SINGLETON
#define DEFINE_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
return __singleton__; \
}


#import <Foundation/Foundation.h>





NS_ASSUME_NONNULL_BEGIN

@interface DBLogerConfigure : NSObject

/// 系统版本号
@property(nonatomic,copy)NSString * systemVersion;
/// app版本号
@property(nonatomic,copy)NSString * appVersion;
/// app的名称
@property(nonatomic,copy)NSString * appName;
/// 系统语言
@property(nonatomic,copy)NSString * language;

/// app版本号
@property(nonatomic,copy)NSString * appSystemVersion;

/// 时间戳，到毫秒
@property(nonatomic,assign)NSString * time;

/// 用户Id
@property(nonatomic,copy)NSString *  userId;

// 业务类型
@property(nonatomic,copy)NSString * businessType;

// YES： 打开日志， NO： 关闭日志
@property(nonatomic,assign)BOOL enableLog;


DECLARE_SINGLETON(DBLogerConfigure);

- (void)setDefaultConfigure;

- (NSString *)getCollectKitUserId;

@end

NS_ASSUME_NONNULL_END

