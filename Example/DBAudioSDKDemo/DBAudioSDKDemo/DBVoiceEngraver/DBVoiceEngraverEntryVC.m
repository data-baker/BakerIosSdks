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
    
    [[XCHudHelper sharedInstance] showHudOnView:self.view caption:@"" image:nil acitivity:YES autoHideTime:0];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [[DBVoiceEngraverManager sharedInstance] setupWithClientId:clientId clientSecret:clientSecret queryId:idfa rePrintType:DBReprintTypeNormal successHandler:^(NSString * _Nonnull msg) {
        [[XCHudHelper sharedInstance] hideHud];
        NSLog(@"获取token成功");
        [self dismissViewControllerAnimated:YES completion:nil];
    } failureHander:^(NSError * _Nonnull error) {
        [[XCHudHelper sharedInstance] hideHud];
        NSLog(@"获取token失败:%@",error);
        NSString *msg = [NSString stringWithFormat:@"获取token失败:%@",error.description];
        [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
    }];}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
