//
//  DBLoginVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/12.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBLoginVC.h"
#import "UIView+Toast.h"
#import "XCHudHelper.h"
#import "DBVoiceTransferUtil.h"
#import "DBUserInfoManager.h"

typedef NS_ENUM(NSInteger,DBAudioSDKType) {
    DBAudioSDKTypeOnlineTTS = 1, // online tts
    DBAudioSDKTypeOneSpeechASR , // one speech asr
    DBAudioSDKTypeLongTimeASR, // long time asr
    DBAudioSDKTypeVoiceTransfer, // voice transfer
    DBAudioSDKTypeVoiceEngraver, // voice Engraver
};

//#error  请联系标贝科技获取clientId 和clientSecret

//static  NSString *clientId = @"XXX";
//static  NSString *clientSecret = @"XXX";

// 离线变声
//static  NSString *clientId = @"0b323b4334a34108ad7468ccc76fdb46";
//static  NSString *clientSecret = @"aba3cd2d68154537b9a27113197dc5b4";

// 声纹服务
static  NSString *clientId = @"6ff8b1e030e64d889293430378d00ba0";
static  NSString *clientSecret = @"feaa5819fb0b47df84d4f4c88351cfb2";



@interface DBLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientSecretTextField;

@end

@implementation DBLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clientIdTextField.text = clientId;
    self.clientSecretTextField.text = clientSecret;
}
- (IBAction)loginAction:(id)sender {
    
    if (self.clientIdTextField.text.length <= 0) {
        [self.view makeToast:@"请输入clentId" duration:2 position:CSToastPositionCenter];
        return ;
    }
    if (self.clientSecretTextField.text.length <= 0 ) {
        [self.view makeToast:@"请输入clentSecret" duration:2 position:CSToastPositionCenter];
        return ;
    }
    NSString *clientId = [self.clientIdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *clientSecret = [self.clientSecretTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[XCHudHelper sharedInstance] showHudOnView:self.view caption:@"" image:nil acitivity:YES autoHideTime:0];
    [DBAuthentication  setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
        // TODO: 暂时关闭
//            if (error) {
//                [[XCHudHelper sharedInstance] hideHud];
//                NSLog(@"获取token失败:%@",error);
//                NSString *msg = [NSString stringWithFormat:@"获取token失败:%@",error.description];
//                [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
//                return;
//            }
            [[XCHudHelper sharedInstance] hideHud];
        [DBUserInfoManager shareManager].clientId = clientId;
        [DBUserInfoManager shareManager].clientSecret = clientSecret;
            [self dismissViewControllerAnimated:YES completion:nil];
        if (self.handler) {
            self.handler();
        }
        }];
     
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.clientIdTextField resignFirstResponder];
    [self.clientSecretTextField resignFirstResponder];
}
@end
