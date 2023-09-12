//
//  DBRecordCompleteVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/5.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBRecordCompleteVC.h"
#import "DBVoiceEngraverManager.h"
#import "UIView+Toast.h"

@interface DBRecordCompleteVC ()
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;
@property(nonatomic,strong)DBVoiceEngraverManager * voiceEngraverManager;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation DBRecordCompleteVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.voiceEngraverManager =  [DBVoiceEngraverManager sharedInstance];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (IBAction)handleCompleteButtonAction:(id)sender {
    
    BOOL flag = [self checkPhoneNumber];
    if (flag) {
        [self sumbmitActionWithPhoneNumber:self.phoneTextField.text];
    }else {
        [self.view makeToast:@"请输入正确的手机号" duration:2 position:CSToastPositionCenter];
    }
    
}
- (IBAction)jumpToTrainAction:(id)sender {
    [self sumbmitActionWithPhoneNumber:@""];
}


- (void)sumbmitActionWithPhoneNumber:(NSString *)phoneNumber {
    [self.voiceEngraverManager startModelTrainRecordVoiceWithPhoneNumber:phoneNumber notifyUrl:nil successHandler:^(DBVoiceModel * _Nonnull voiceModel) {
        NSLog(@"voiceModelId %@",voiceModel.modelId);
        [self showAlertVCWithMessage:@"上传模型训练成功,点击确定跳转体验声音页面"];
    }  failureHander:^(NSError * _Nonnull error) {
        [self.view makeToast:[NSString stringWithFormat:@"%@",error.description] duration:3 position:CSToastPositionCenter];
        
    }];
}

- (BOOL)checkPhoneNumber {
    NSString * MOBILE = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if ([regextestmobile evaluateWithObject:self.phoneTextField.text] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)showAlertMessage {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请填写手机号开启模型训练" preferredStyle:UIAlertControllerStyleAlert];
       UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"跳过" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
              
          }];
       [alertVC addAction:cancelAction];

       UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          
       }];
       [alertVC addAction:doneAction];
       [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)showAlertVCWithMessage:(NSString *)message {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"跳转提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *jumpAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.tabBarController.viewControllers.count>0) {
            [self.tabBarController setSelectedIndex:1];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertVC addAction:jumpAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.phoneTextField resignFirstResponder];
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
