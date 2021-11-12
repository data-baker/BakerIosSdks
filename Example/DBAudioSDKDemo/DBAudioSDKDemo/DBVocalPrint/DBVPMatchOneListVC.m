//  DBVPMatchOneListVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import "DBVPMatchOneListVC.h"
#import "DBVPMatchReadVC.h"


@interface DBVPMatchOneListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tabview;
@property(nonatomic,copy)NSArray * datasource;

@end

@implementation DBVPMatchOneListVC



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabview.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadMatchList];
}

// MARK: Load data
- (void)loadMatchList {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *list = [userDefault arrayForKey:userMatchId];
    self.datasource = list;
    [self.tabview reloadData];
    if (list.count == 0) {
        [self.view makeToast:@"当前列表数据为空" duration:1.5f position:CSToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}



// MAKR: UITableViewDelegate & UItableviewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    NSDictionary *dict = self.datasource[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@-%@",dict[matchName],dict[matchId]];
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBVPMatchReadVC *readVC = [[UIStoryboard storyboardWithName:@"DBVPStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"DBVPMatchReadVC"];
    NSDictionary *dict = self.datasource[indexPath.row];
    readVC.accessToken = self.accessToken;
    readVC.threshold = self.threshold;
    readVC.matchId = dict[matchId];
    readVC.matchName = dict[matchName];
    [self.navigationController pushViewController:readVC animated:YES];
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
