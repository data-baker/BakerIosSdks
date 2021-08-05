//
//  DBVoiceListVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceListVC.h"
#import "DBVoiceExperienceVC.h"
#import "DBVoiceEngraverManager.h"
#import "UIView+Toast.h"
#import "XCHudHelper.h"
#import <AdSupport/AdSupport.h>

@interface DBVoiceListVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITabBarControllerDelegate>
@property(nonatomic,strong)NSMutableArray * dataSource;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(nonatomic,strong)DBVoiceEngraverManager * voiceEngraverManager;

@end

@implementation DBVoiceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.voiceEngraverManager = [DBVoiceEngraverManager sharedInstance];
    self.tabBarController.delegate = self;
    [self loadListData];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

// MARK: network Methods

- (void)loadListData {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    [[XCHudHelper sharedInstance] showHudOnView:self.view caption:@"" image:nil acitivity:YES autoHideTime:0];
    [self.voiceEngraverManager batchQueryModelStatusByQueryId:idfa SuccessHandler:^(NSArray<DBVoiceModel *> * _Nonnull array) {
        [[XCHudHelper sharedInstance] hideHud];
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:array];
        [self.collectionView reloadData];
    } failureHander:^(NSError * _Nonnull error) {
        [[XCHudHelper sharedInstance] hideHud];
        [self.view makeToast:error.description duration:2.f position:CSToastPositionCenter];
    }];
}

- (void)loadModelByModelId:(NSString *)modelId {
    [self.voiceEngraverManager queryModelStatusByModelId:modelId SuccessHandler:^(DBVoiceModel * _Nonnull voiceModel) {
        NSLog(@"voiceMode %@",voiceModel);
    } failureHander:^(NSError * _Nonnull error) {
        
    }];
}
  


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DBExperienceCellID" forIndexPath:indexPath];
    
    DBVoiceModel *model = self.dataSource[indexPath.row];
    UILabel * label = [cell.contentView viewWithTag:101];
    label.text = @(indexPath.row +1).stringValue;
    
    UILabel *statusLabel = [cell.contentView viewWithTag:102];
    statusLabel.text = model.statusName;
    UILabel *modelIdLabel = [cell.contentView viewWithTag:103];
    modelIdLabel.text = model.modelId;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(110, 144);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    if (self.dataSource.count == 1) {
        /// 单个cell时强制布局到最左侧
        return UIEdgeInsetsMake(0, 0, 0,self.view.frame.size.width-20*2 - 110);

    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //   DBVoiceExperienceVC *voiceExperienceVC = [[DBVoiceExperienceVC alloc]init];
    //    [self.navigationController pushViewController:voiceExperienceVC animated:YES];
    DBVoiceModel *model = self.dataSource[indexPath.row];
    
//    if (![[NSString stringWithFormat:@"%@",model.modelStatus] isEqualToString:@"6"]) {
//        [self.view makeToast:@"请训练成功后再试" duration:2 position:CSToastPositionCenter];
//        return ;
//
//    }
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"DBVoiceExperience" bundle:[NSBundle mainBundle]];
    DBVoiceExperienceVC *experienceVC  =  [story instantiateViewControllerWithIdentifier:@"DBVoiceExperienceVC"];
    experienceVC.voiceModel = model;
    [self.navigationController pushViewController:experienceVC animated:YES];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
        [self loadListData];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
