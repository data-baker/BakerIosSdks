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

//#error  请设置clientId 和clientSecret
static  NSString *clientId1 = @"bb4f7ecb-a4bd-42dd-935a-ba6c64b12f4f";
static  NSString *clientSecret1 = @"Zjc3Y2NjOTItZGFkOC00NmVhLWJiZmEtOTkwY2Q0YmNhNzJi";

@interface DBLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientSecretTextField;

@end

@implementation DBLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.clientIdTextField.text = @"4020bc7b-13f2-4080-b406-45ad06e3ccb7";
//    self.clientSecretTextField.text = @"NGVjNmNmNmEtMmFkYS00YWIxLWFmYjEtYjE1MTNjYWYyN2E4";
    self.clientIdTextField.text = clientId1;
    self.clientSecretTextField.text = clientSecret1;
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
    [[DBVoiceTransferUtil shareInstance] setupClientId:clientId clientSecret:clientSecret block:^(NSString * _Nullable token, NSError * _Nullable error) {
            if (error) {
                [[XCHudHelper sharedInstance] hideHud];
                NSLog(@"获取token失败:%@",error);
                NSString *msg = [NSString stringWithFormat:@"获取token失败:%@",error.description];
                [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
                return;
            }
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
