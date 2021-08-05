//
//  DBNoiseDetectionVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/3.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBNoiseDetectionVC.h"
#import "DBVoiceDetectionUtil.h"
#import "DBVoiceEngraverManager.h"
#import "UIView+Toast.h"
#import "DBRecordTextVC.h"
#import "XCHudHelper.h"

@interface DBNoiseDetectionVC ()<DBVoiceDetectionDelegate>
@property(nonatomic,strong)DBVoiceDetectionUtil * voiceDetectionUtil;
@property(nonatomic,strong)DBVoiceEngraverManager * voiceEngraverManager;
@property (weak, nonatomic) IBOutlet UIButton *volumeNumberButton;
@property (weak, nonatomic) IBOutlet UILabel *volumeTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *startEngraverVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeDetectButton;
@end

@implementation DBNoiseDetectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.volumeNumberButton.layer.cornerRadius = 81;
    self.volumeNumberButton.layer.masksToBounds = YES;
    self.volumeNumberButton.layer.borderWidth = 1;
   [self setButtonNumberColor:[UIColor systemBlueColor]];
    self.volumeNumberButton.backgroundColor = [UIColor whiteColor];
    self.voiceEngraverManager = [DBVoiceEngraverManager sharedInstance];
    /// 声明噪音检测的工具，开启噪音检测
    self.voiceDetectionUtil = [[DBVoiceDetectionUtil alloc]init];
    self.startEngraverVoiceButton.enabled = NO;
    self.voiceDetectionUtil.delegate = self;
    DBErrorState state =  [self.voiceDetectionUtil startDBDetection];
    if (state == DBErrorStateMircrophoneNotPermission) {
        [self.view makeToast:@"请打开麦克风权限再试" duration:2 position:CSToastPositionCenter];
    }else  if (state == DBErrorStateNOError) {
        NSLog(@"开启检测成功");
    }else {
        NSLog(@"开启检测失败");
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)resumeDetectNoise:(id)sender {
    [self.voiceDetectionUtil startDBDetection];
}
- (IBAction)startEngraverAction:(id)sender {
    [self showHUD];
    [self.voiceEngraverManager getRecordTextArrayTextHandler:^(NSArray * _Nonnull textArray) {
        [self hiddenHUD];
        if (textArray.count == 0) {
            [self.view makeToast:@"获取录制文本失败" duration:2 position:CSToastPositionCenter];
            return ;
        }
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DBRecordTextVC *recordVC  =   [story instantiateViewControllerWithIdentifier:@"DBRecordTextVC"];
        recordVC.textArray = textArray;
        [self.navigationController pushViewController:recordVC animated:YES];
    } failure:^(NSError * _Nonnull error) {
        [self hiddenHUD];
        [self.view makeToast:error.description duration:2 position:CSToastPositionCenter];
    }];
}


// MARK: DBVoiceDetectionDelegate

- (void)dbDetecting:(NSInteger)volumeDB {
     [self.volumeNumberButton setTitle:[NSString stringWithFormat:@"%@分贝",@(volumeDB).stringValue] forState:UIControlStateNormal];
}

- (void)dbDetectionResult:(BOOL)result value:(NSInteger)volumeDB {
    self.resumeDetectButton.hidden = NO;
    if (!result) {
        NSLog(@"检测分贝数失败");
        return ;
    }
    
    self.volumeTextLabel.hidden = NO;
    [self.volumeNumberButton setTitle:[NSString stringWithFormat:@"%@分贝",@(volumeDB).stringValue] forState:UIControlStateNormal];
    if (volumeDB > 70) {
        self.volumeTextLabel.text = @"环境太差，请稍后再试吧";
        self.startEngraverVoiceButton.enabled = NO;
        self.resumeDetectButton.hidden = NO;
        [self setButtonNumberColor:[UIColor orangeColor]];
    }else if (volumeDB > 50) {
        self.resumeDetectButton.hidden = YES;
        self.volumeTextLabel.text = @"环境一般，换个地方吧";
        self.startEngraverVoiceButton.enabled = YES;
        [self setButtonNumberColor:[UIColor systemBlueColor]];
    }else {
        self.volumeTextLabel.text = @"环境很静，开始复刻吧";
        self.startEngraverVoiceButton.enabled = YES;
        self.resumeDetectButton.hidden = YES;
        [self setButtonNumberColor:[UIColor greenColor]];
    }
}

- (void)setButtonNumberColor:(UIColor *)color {
    self.volumeNumberButton.layer.borderColor = color.CGColor;
    [self.volumeNumberButton setTitleColor:color forState:UIControlStateNormal];
}
// MARK: HUD的hidding
- (void)showHUD {
    [[XCHudHelper sharedInstance]showHudOnView:self.view caption:@"" image:nil
                                     acitivity:YES autoHideTime:30];
}

- (void)hiddenHUD {
    [[XCHudHelper sharedInstance]hideHud];
}

#pragma mark - Navigation



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    self.navigationController.tabBarController.hidesBottomBarWhenPushed= NO;
}


@end
