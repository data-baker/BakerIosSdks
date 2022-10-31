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

//#error  请联系标贝科技获取clientId 和clientSecret, 注意不同的服务使用不同的授权clientId和clientSecret

// 测试的授权，tts
//static  NSString *clientId = @"3fa40e3571fa47be8093c739bb590db0";
//static  NSString *clientSecret = @"9c4e97f1edcb48768e30707d82dee2b6";

// 测试的授权， 长语音
static NSString *clientId = @"xxx";
static NSString *clientSecret = @"xxx";



@interface DBLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientSecretTextField;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation DBLoginVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subtitleLabel.text = self.subtitle;
     
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
