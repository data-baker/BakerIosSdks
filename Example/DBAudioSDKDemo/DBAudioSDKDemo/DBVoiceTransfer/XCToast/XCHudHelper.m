//
//  XFHudHelper.m
//
//  Created by TopDev on 10/23/14.
//  Copyright (c) 2014 TopDev. All rights reserved.
//

#import "XCHudHelper.h"

@implementation XCHudHelper

+ (XCHudHelper *)sharedInstance {
    static XCHudHelper *_instance = nil;
    
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

- (void)showHudAcitivityOnWindow
{
    [self showHudOnWindow:nil image:nil acitivity:YES autoHideTime:0];
}

- (void)showHudOnWindow:(NSString *)caption
                  image:(UIImage *)image
              acitivity:(BOOL)active
           autoHideTime:(NSTimeInterval)time1 {
    
    if (_hud) {
        [_hud hideAnimated:NO];
    }
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] delegate].window];
    [[[UIApplication sharedApplication] delegate].window addSubview:self.hud];
    self.hud.label.text = caption;
    self.hud.customView = [[UIImageView alloc] initWithImage:image];
    self.hud.customView.bounds = CGRectMake(0, 0, 100, 100);
    self.hud.mode = image ? MBProgressHUDModeCustomView : MBProgressHUDModeIndeterminate;
    self.hud.animationType = MBProgressHUDAnimationFade;
    self.hud.removeFromSuperViewOnHide = YES;
    [self.hud showAnimated:YES];
    if (time1 > 0) {
        [self.hud hideAnimated:YES afterDelay:time1];
    }
}

- (void)showHudOnView:(UIView *)view
              caption:(NSString *)caption
                image:(UIImage *)image
            acitivity:(BOOL)active
         autoHideTime:(NSTimeInterval)time1 {
    
    if (_hud) {
        [_hud hideAnimated:NO];
    }
    
    self.hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:self.hud];
    self.hud.label.text = caption;
    self.hud.customView = [[UIImageView alloc] initWithImage:image];
    self.hud.customView.bounds = CGRectMake(0, 0, 100, 100);
    self.hud.mode = image ? MBProgressHUDModeCustomView : MBProgressHUDModeIndeterminate;
    self.hud.animationType = MBProgressHUDAnimationFade;
    [self.hud showAnimated:YES];
    if (time1 > 0) {
        [self.hud hideAnimated:YES afterDelay:time1];
    }
}

- (void)setCaption:(NSString *)caption {
    self.hud.label.text = caption;
}


- (void)hideHud {
    if (_hud) {
        [_hud hideAnimated:YES];
    }
}

- (void)hideHudAfter:(NSTimeInterval)time1 {
    if (_hud) {
        [_hud hideAnimated:YES afterDelay:time1];
    }
}


+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}



+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark ????????????
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // ??????????????????????????????
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // ????????????
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // ???????????????
    hud.mode = MBProgressHUDModeCustomView;
    
    // ?????????????????????????????????
    hud.removeFromSuperViewOnHide = YES;
    
    // 1.0??????????????????
    [hud hideAnimated:YES afterDelay:1.0];
}


+ (void)showMessage:(NSString *)message
{
    [self show:message icon:@"" view:nil];
}

+ (void)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // ??????????????????????????????
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // ?????????????????????????????????
    hud.removeFromSuperViewOnHide = YES;
    // YES????????????????????????
    //hud.dimBackground = YES;
    // 100??????????????????
    [hud hideAnimated:YES afterDelay:100.0];
}


+ (void)hideHUD
{
    UIView *view = [[UIApplication sharedApplication].windows lastObject];
    [MBProgressHUD hideHUDForView:view animated:YES];
}
@end
