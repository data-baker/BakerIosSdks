//
//  ViewController.m
//  DBASRDemo(002)
//
//  Created by linxi on 2021/2/1.
//

#import "ViewController.h"
#import "DBUserInfoManager.h"
#import "DBLoginVC.h"

@interface ViewController ()
//@property(nonatomic,strong)UIButton * clickButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
//    self.clickButton = (UIButton *)sender;
    DBUserInfoManager *manager = [DBUserInfoManager shareManager];
    if (!manager.clientId || !manager.clientSecret) {
        [self showLogInVC];
        return NO;
    }
    return YES;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
    
    UIViewController *vc = segue.destinationViewController;

}

- (void)showLogInVC {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DBLoginVC *loginVC  =   [story instantiateViewControllerWithIdentifier:@"DBLoginVC"];
//    loginVC.handler = ^{
//        NSString *title = self.clickButton.titleLabel.text;
        
//    };
//    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:loginVC animated:YES completion:nil];
}


@end
