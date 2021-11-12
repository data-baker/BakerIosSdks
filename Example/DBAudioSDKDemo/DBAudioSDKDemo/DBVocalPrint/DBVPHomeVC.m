//
//  DBVPHomeVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import "DBVPHomeVC.h"
#import "DBVPMatchReadVC.h"


@interface DBVPHomeVC ()

@end

@implementation DBVPHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL ret = [segue.destinationViewController isKindOfClass:[DBVPMatchReadVC class]];
    if (ret) {
        DBVPMatchReadVC *readVC = (DBVPMatchReadVC *)segue.destinationViewController;
        readVC.isMatchMore = YES;

    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
