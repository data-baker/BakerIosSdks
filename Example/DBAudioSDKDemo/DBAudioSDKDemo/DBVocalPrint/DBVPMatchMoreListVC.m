//
//  DBVPMatchMoreListVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import "DBVPMatchMoreListVC.h"
#import "DBVPResponseModel.h"

@interface DBVPMatchMoreListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tabview;
@end

@implementation DBVPMatchMoreListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabview.tableFooterView = [UIView new];
    [self.tabview reloadData];
}
- (IBAction)closeAction:(id)sender {
    [self popToListVC];
}
- (void)popToListVC {
    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:vc animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    DBMatchListModel *model = self.datasource[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@ 分数：%.1f",model.name,model.spkid,[model.score floatValue]];
//    NSDictionary *dict = self.datasource[indexPath.row];
//    NSString *text = [NSString stringWithFormat:@"%@-%@",dict[matchName],dict[matchId]];
//    cell.textLabel.text = text;
    return cell;
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
