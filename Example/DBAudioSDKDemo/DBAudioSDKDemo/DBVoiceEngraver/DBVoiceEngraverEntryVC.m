//
//  DBVoiceEngraverEntryVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/8/5.
//

#import "DBVoiceEngraverEntryVC.h"
#import "DBUserInfoManager.h"
#import "UIView+Toast.h"
#import "XCHudHelper.h"
#import <AdSupport/AdSupport.h>
#import "DBVoiceEngraverManager.h"

@interface DBVoiceEngraverEntryVC ()

@end

@implementation DBVoiceEngraverEntryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    NSString * sdkType = [DBUserInfoManager shareManager].sdkType;
    
    [[XCHudHelper sharedInstance] showHudOnView:self.view caption:@"" image:nil acitivity:YES autoHideTime:0];
    NSString *UDID = [[NSUUID UUID] UUIDString];
    UDID = [clientId stringByAppendingFormat:@"_%@",UDID];
    [KUserDefalut setObject:UDID forKey:KUDID];
    NSLog(@"queryId:%@",UDID);
    [[DBVoiceEngraverManager sharedInstance] setupWithClientId:clientId clientSecret:clientSecret queryId:UDID rePrintType:[self reprintSDKType:sdkType] successHandler:^(NSString * _Nonnull msg) {
        [[XCHudHelper sharedInstance] hideHud];
        NSLog(@"获取token成功");
        [self dismissViewControllerAnimated:YES completion:nil];
    } failureHander:^(NSError * _Nonnull error) {
        [[XCHudHelper sharedInstance] hideHud];
        NSLog(@"获取token失败:%@",error);
        NSString *msg = [NSString stringWithFormat:@"获取token失败:%@",error.description];
        [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
    }];}

- (DBReprintType)reprintSDKType:(NSString *)sdkType {
    if ([sdkType isEqualToString:@"声音复刻普通"]) {
        return DBReprintTypeNormal;
    }else if ([sdkType isEqualToString:@"声音复刻精品"]) {
        return DBReprintTypeFine;
    }
    NSLog(@"[error], default select Reprint Normal");
    return DBReprintTypeNormal;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
