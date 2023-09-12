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

#ifndef KUserDefalut
#define KUserDefalut [NSUserDefaults standardUserDefaults]
#endif

static NSString * KRecordSessionIDNormal = @"KRecordSessionIdNormal"; // 录制过程中生成的SessionId,普通
static NSString * KRecordSessionIDFine = @"KRecordSessionIdFine"; // 录制过程中生成的SessionId，精品

@interface DBNoiseDetectionVC ()<DBVoiceDetectionDelegate,DBSessionIdDelegate>
@property(nonatomic,strong)DBVoiceDetectionUtil * voiceDetectionUtil;
@property(nonatomic,strong)DBVoiceEngraverManager * voiceEngraverManager;
@property (weak, nonatomic) IBOutlet UIButton *volumeNumberButton;
@property (weak, nonatomic) IBOutlet UILabel *volumeTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *startEngraverVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *resumeDetectButton;
@property(nonatomic,assign)NSInteger noiseMaxLimit; // 噪音的上限
@end

@implementation DBNoiseDetectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.volumeNumberButton.layer.cornerRadius = 81;
    self.volumeNumberButton.layer.masksToBounds = YES;
    self.volumeNumberButton.layer.borderWidth = 1;
    [self recoverUIState];
    self.voiceEngraverManager = [DBVoiceEngraverManager sharedInstance];
    [self loadNoiseConfigure:^(NSString *msg) {
        self.noiseMaxLimit = [msg integerValue] + 10;
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
    }];
   
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
// MARK: Load Noise configure
- (void)loadNoiseConfigure:(DBMessageHandler)handler {
    [self.voiceEngraverManager getNoiseLimit:^(NSString *msg) {
        handler(msg);
    } failuer:^(NSError * _Nonnull error) {
        [self.view makeToast:error.localizedDescription];
    }];
}

// MARK:

- (void)recoverUIState {
    self.volumeTextLabel.hidden = YES;
    [self setButtonNumberColor:[UIColor systemBlueColor]];
    self.volumeNumberButton.backgroundColor = [UIColor whiteColor];
}

- (IBAction)resumeDetectNoise:(id)sender {
    [self recoverUIState];
    [self.voiceDetectionUtil startDBDetection];
}
- (IBAction)startEngraverAction:(id)sender {
    [self showHUD];
    NSString *sessionId = [self getCurrentSessionId];
    [self.voiceEngraverManager getTextArrayWithSeesionId:sessionId textHandler:^(NSInteger index, NSArray<DBTextModel *> * _Nonnull array,NSString *backSessionId) {
        [self hiddenHUD];
        if (array.count == 0) {
            [self.view makeToast:@"获取录制文本失败" duration:2 position:CSToastPositionCenter];
            return ;
        }
        // 保存当前录制的SessionId和进度
        if(backSessionId) {
            [self setCurrentSessionId:backSessionId];
        }
        if(![backSessionId isEqualToString:sessionId] && sessionId != nil) {
           // Session已经过期，会重新sessionId
            [self showResumAlertHandler:^{
                [self pushTextVCWithIndex:0 textArray:array];
            }];
            return;
        }
        
        if (index == 0) { // 如果会话中没有录制，直接进入
            [self pushTextVCWithIndex:0 textArray:array];
            return;
        }
        
        [self showContinueReprintAlertHandler:^{
            [self pushTextVCWithIndex:index textArray:array];
        }cancelHandler:^{
            // 先停止会话
            [self.voiceEngraverManager unNormalStopRecordSeesionSuccessHandler:^(NSString *msg) {
                [self removeCurrentSessionId];
                // 再次开启一个会话
                [self startEngraverAction:nil];
            } failureHandler:^(NSError * _Nonnull error) {
                [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionCenter];
            }];
        }];

    } failure:^(NSError * _Nonnull error) {
        if (error.code == DBErrorStateModuleIdInvailid) { // 模型不存在
            [self removeCurrentSessionId];
        }
        [self hiddenHUD];
        [self.view makeToast:error.description duration:2 position:CSToastPositionCenter];
    }];
}

- (void)pushTextVCWithIndex:(NSInteger)index textArray:(NSArray<DBTextModel *> *)modelArray {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DBRecordTextVC *recordVC  =   [story instantiateViewControllerWithIdentifier:@"DBRecordTextVC"];
    recordVC.textArray = modelArray;
    recordVC.index = index;
    recordVC.delegate = self;
    [self.navigationController pushViewController:recordVC animated:YES];
}
// 展示检测的弹窗

- (void)showContinueReprintAlertHandler:(dispatch_block_t)handler cancelHandler:(dispatch_block_t)cancelHandler {
    NSAssert2(handler&&cancelHandler, @"Please setting the handler:%@, cancel handler:%@", handler, cancelHandler);
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"检测到您有复刻录制正在进行中，是否继续录制? " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"重新录制" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        cancelHandler();
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *resume = [UIAlertAction actionWithTitle:@"继续录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler();
    }];
    [alertVC addAction:resume];
    [self presentViewController:alertVC animated:YES completion:nil];
}


- (void)showResumAlertHandler:(dispatch_block_t)handler {
    NSAssert(handler, @"Please setting the handler:%@", handler);
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"检测到您当前会话已失效，需要重新录制" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"重新录制" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        handler();
    }];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// MARK: DBVoiceDetectionDelegate
- (void)dbDetecting:(NSInteger)volumeDB {
     [self.volumeNumberButton setTitle:[NSString stringWithFormat:@"%@分贝",@(volumeDB).stringValue] forState:UIControlStateNormal];
}

- (void)dbAudioInterrupted {
    [self detectFailedWithText:@"音频被打断，检测失败"];
}

- (void)dbDetectionResult:(BOOL)result value:(NSInteger)volumeDB {
    self.resumeDetectButton.hidden = NO;
    if (!result) {
        NSLog(@"检测分贝数失败");
        return ;
    }
    [self.volumeNumberButton setTitle:[NSString stringWithFormat:@"%@分贝",@(volumeDB).stringValue] forState:UIControlStateNormal];
    if (volumeDB > self.noiseMaxLimit) {
        [self detectFailedWithText:@"环境太差，请稍后再试吧"];
    }else if (volumeDB > 50) {
        self.volumeTextLabel.hidden = NO;
        self.resumeDetectButton.hidden = YES;
        self.volumeTextLabel.text = @"环境一般，换个地方吧";
        self.startEngraverVoiceButton.enabled = YES;
        [self setButtonNumberColor:[UIColor systemBlueColor]];
    }else {
        self.volumeTextLabel.hidden = NO;
        self.volumeTextLabel.text = @"环境很静，开始复刻吧";
        self.startEngraverVoiceButton.enabled = YES;
        self.resumeDetectButton.hidden = YES;
        [self setButtonNumberColor:[UIColor greenColor]];
    }
}
- (void)detectFailedWithText:(NSString *)text {
    self.volumeTextLabel.hidden = NO;
    self.volumeTextLabel.text = text;
    self.startEngraverVoiceButton.enabled = NO;
    self.resumeDetectButton.hidden = NO;
    [self setButtonNumberColor:[UIColor orangeColor]];
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
- (void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    self.navigationController.tabBarController.hidesBottomBarWhenPushed= NO;
}

// MARK: ---DBSessionIdDelegate ---
- (NSString *)getCurrentSessionId {
    DBReprintType type = [self.voiceEngraverManager currentType];
    NSString *sessionId;
    switch (type) {
        case DBReprintTypeNormal:
            sessionId =  [KUserDefalut objectForKey:KRecordSessionIDNormal];
            break;
        case DBReprintTypeFine:
            sessionId =  [KUserDefalut objectForKey:KRecordSessionIDFine];
            break;
    }
    return sessionId;
}

- (void)setCurrentSessionId:(NSString *)sessionId {
    if(sessionId.length == 0 || sessionId == nil) {
        NSLog(@"[debug]:保存的SessionId 不能为空");
        return;
    }
    DBReprintType type = [self.voiceEngraverManager currentType];
    switch (type) {
        case DBReprintTypeNormal:
            [KUserDefalut setObject:sessionId forKey:KRecordSessionIDNormal];
            break;
        case DBReprintTypeFine:
            [KUserDefalut setObject:sessionId forKey:KRecordSessionIDFine];
            break;
    }
}

- (void)removeCurrentSessionId {
    DBReprintType type = [self.voiceEngraverManager currentType];
    switch (type) {
        case DBReprintTypeNormal:
            [KUserDefalut removeObjectForKey:KRecordSessionIDNormal];
            break;
        case DBReprintTypeFine:
            [KUserDefalut removeObjectForKey:KRecordSessionIDFine];
            break;
    }
}



@end
