//
//  DBLogerModel.m
//  DBCrashLogKit
//
//  Created by biaobei on 2022/4/27.
//

#import "DBLogerConfigure.h"
#import "DBCommonConst.h"

static NSString *KUserIdKey = @"KUserIdKey";

@implementation DBLogerConfigure

DEFINE_SINGLETON(DBLogerConfigure);

- (void)setDefaultConfigure {
    self.businessType = @"bbyy-sdk-ios";
    self.language = @"zh";
    self.systemVersion = [DBCommonConst getCurrentDeviceModel];
    self.appVersion = KAUDIO_SDK_VERSION;
    self.userId = [self getCollectKitUserId];
    self.appSystemVersion = [DBCommonConst systemVersion];
    self.appName = @"AuduioSDK";
    self.enableLog = YES;
}

- (NSString *)getCollectKitUserId {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *uuidString = [userDefault objectForKey:KUserIdKey];
    if(IsEmpty(uuidString)) {
        uuidString = [NSUUID UUID].UUIDString;
        [[NSUserDefaults standardUserDefaults]setObject:uuidString forKey:KUserIdKey];
    }
    return uuidString;
}



- (NSString *)time {
    return [self getUnixTime];
}
- (NSString *)getUnixTime{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
    long long int currentTime = (long long int)time;
    NSString *unixTime = [NSString stringWithFormat:@"%llu", currentTime];
    return unixTime;
}

@end
