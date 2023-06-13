//
//  ViewController.m
//  DBASRDemo(002)
//
//  Created by linxi on 2021/2/1.
//

#import "ViewController.h"
#import "DBUserInfoManager.h"
#import "DBLoginVC.h"
#ifdef DEBUG
//#import <DoraemonKit/DoraemonManager.h>
//#import "DoraemonUtil.h"
//#import <DoraemonKit/DoraemonKit.h>
//#import <DoraemonKit/DoraemonAppInfoViewController.h>
//#import "DoraemonTimeProfiler.h"
//#import "DoraemonKitDemoi18Util.h"
#endif

@interface ViewController ()
//@property(nonatomic,strong)UIButton * clickButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//#ifdef DEBUG
//    [[DoraemonManager shareInstance] installWithPid:@"749a0600b5e48dd77cf8ee680be7b1b7"];//productId为在“平台端操作指南”中申请的产品id
//    
//    [[DoraemonManager shareInstance] addPluginWithTitle:DoraemonDemoLocalizedString(@"测试插件") icon:@"doraemon_default" desc:DoraemonDemoLocalizedString(@"测试插件") pluginName:@"TestPlugin" atModule:DoraemonDemoLocalizedString(@"业务工具")];
//#endif
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    UIButton * clickButton = (UIButton *)sender;
    NSString *title = clickButton.titleLabel.text;
    NSLog(@"点击了：%@",title);
    
    DBUserInfoManager *manager = [DBUserInfoManager shareManager];
    if (!manager.clientId || !manager.clientSecret || ![manager.sdkType isEqualToString:title]) {
        [self showLogInVCWithTitle:title identifier:identifier sender:sender];
    }
    
    return YES;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
}

- (BOOL)showLogInVCWithTitle:(NSString *)title identifier:(NSString *)identifier sender:(id)sender {
    __block BOOL enter = YES;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DBLoginVC *loginVC = [story instantiateViewControllerWithIdentifier:@"DBLoginVC"];
    loginVC.sdkName = title;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    loginVC.handler = ^(BOOL ret){
        enter = ret;
        dispatch_semaphore_signal(semaphore);
        if(ret == NO) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:loginVC animated:YES completion:nil];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return enter;
}


@end
