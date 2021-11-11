//
//  DBVPRegisterInfoVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/9.
//

#import "DBVPRegisterInfoVC.h"
#import "UIView+Toast.h"
#import "DBVPRegisterReadVC.h"
#import "DBVocalPrintClient.h"
#import "DBUserInfoManager.h"



@interface DBVPRegisterInfoVC ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *thresholdTextField;
@property(nonatomic,copy)NSString * accessToken;
@property(nonatomic,strong)DBVocalPrintClient * vpClient;

@end

@implementation DBVPRegisterInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* TODO - 80.1 验证不成功， 50-60分是正常的水平*/
    self.nameTextField.text = @"林喜的声纹";
    
    self.thresholdTextField.text = @"60.1";
    
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    self.vpClient = [DBVocalPrintClient shareInstance];
    __weak typeof(self) weakSelf = self;
    [self.vpClient setupClientId:clientId clientSecret:clientSecret handler:^(BOOL ret, NSString * _Nullable msg) {
        typeof(self) strongSelf = weakSelf;
        if (!ret) {
            [strongSelf.view makeToast:msg duration:1.5 position:CSToastPositionCenter];
            return;
        }
        self.accessToken = msg;
        NSLog(@"token:%@",self.accessToken);
        
       
    }];
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if (self.accessToken.length == 0) {
        [self.view makeToast:@"请在access Token获取成功后再试 " duration:1.5 position:CSToastPositionCenter];
        return NO;
    }
    
    if (self.nameTextField.text.length == 0 ) {
        [self.view makeToast:@"请填写声纹注册的名字" duration:1.5 position:CSToastPositionCenter];
        return NO;
    }else if (self.thresholdTextField.text.length == 0) {
        [self.view makeToast:@"请填写声纹注册的阈值分数" duration:1.5 position:CSToastPositionCenter];
        return NO;
    }
    
    return  YES;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DBVPRegisterReadVC *readVC = [segue destinationViewController];
    readVC.name = self.nameTextField.text;
    readVC.threshold =  @([self.thresholdTextField.text floatValue]);
    readVC.accessToken = self.accessToken;
    readVC.vpClient = self.vpClient;
}


@end
