//
//  DBVPMatchSuccessVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import "DBVPMatchSuccessVC.h"

@interface DBVPMatchSuccessVC ()
@property (weak, nonatomic) IBOutlet UILabel *vpInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchResultLabel;

@end

@implementation DBVPMatchSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat scoreFloat =  [self.score floatValue];
    if (scoreFloat < 20) {
        self.matchResultLabel.textColor = [UIColor redColor];
        self.matchResultLabel.text = @"验证失败";
        self.vpInfoLabel.text = [NSString stringWithFormat:@"%@ \n 声纹ID:%@ \n 分数：%.1f",self.matchName,self.matchId,scoreFloat];
    }else {
        self.matchResultLabel.textColor = [UIColor greenColor];
        self.matchResultLabel.text = @"验证成功";
        self.vpInfoLabel.text = [NSString stringWithFormat:@"%@ \n 声纹ID:%@ \n 分数：%.1f",self.matchName,self.matchId,scoreFloat];
    }
 
}
- (IBAction)closeAction:(id)sender {
    [self popToListVC];
    
}
- (void)popToListVC {
    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:vc animated:YES];
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
