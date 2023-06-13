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
//static NSString *clientId = @"XXX";
//static NSString *clientSecret = @"XXX";

#define KUserDefalut [NSUserDefaults standardUserDefaults]

@interface DBLoginVC ()
{
    NSString *keyName_;
}
@property (weak, nonatomic) IBOutlet UITextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *clientSecretTextField;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation DBLoginVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.sdkName;
    self.subtitleLabel.text = @"请输入授权信息";
    [self restoreUserInfo];
}

- (void)restoreUserInfo {
    NSDictionary *dict = @{
        @"一句话识别":@"oneShot",
        @"实时长语音识别":@"longSpeech",
        @"在线语音合成":@"onlineTTS",
        @"声音转换":@"voiceConvert",
        @"声音复刻":@"voiceReprint",
        @"离线变声":@"offlieVC",
        @"声纹服务":@"voiceprint"
    };
    NSString *key = dict[_sdkName];
    NSAssert(key, @"key can't be nil");
    keyName_ = key;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *authInfo  = [ud objectForKey:key];
    NSString *clientId = authInfo[@"clientId"];
    NSString *clientSecret = authInfo[@"clientSecret"];
    if (clientId.length > 0 && clientSecret.length > 0) {
        self.clientIdTextField.text = clientId;
        self.clientSecretTextField.text = clientSecret;
    }else {
        [ud removeObjectForKey:key];
    }
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
        if (error) {
            [[XCHudHelper sharedInstance] hideHud];
            NSLog(@"获取token失败:%@",error);
            NSString *msg = [NSString stringWithFormat:@"获取token失败:%@",error.description];
            [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
            self.handler(NO);
            return;
        }
        [[XCHudHelper sharedInstance] hideHud];
        DBUserInfoManager *infoManager = [DBUserInfoManager shareManager];
        
        infoManager.clientId = clientId;
        infoManager.clientSecret = clientSecret;
        infoManager.sdkType = self.sdkName;
        NSDictionary *authInfo = @{
            @"clientId":clientId,
            @"clientSecret":clientSecret
        };
        [KUserDefalut setObject:authInfo forKey:self->keyName_];
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.handler) {
            self.handler(YES);
        }
        }];
     
}
- (IBAction)comeBack:(UIButton *)sender {
    self.handler(NO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.clientIdTextField resignFirstResponder];
    [self.clientSecretTextField resignFirstResponder];
}
// 增加userDefault 的设置

@end
