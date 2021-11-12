//
//  DBVPMatchReadVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/11.
//

#import "DBVPMatchReadVC.h"
#import "DBAudioMicrophone.h"
#import "UIView+Toast.h"
#import "DBVPMatchSuccessVC.h"
#import "DBVocalPrintClient.h"
#import "DBUserInfoManager.h"
#import "DBVPRegisterReadVC.h"
#import "DBVPMatchMoreListVC.h"
#import "XCHudHelper.h"


@interface DBVPMatchReadVC ()<DBAudioMicrophoneDelegate>
@property(nonatomic,strong)DBVocalPrintClient * vpClient;
@property(nonatomic,strong)DBAudioMicrophone * microphone;
@property(nonatomic,strong)NSMutableData * recordData;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
@property (weak, nonatomic) IBOutlet UILabel *matchInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation DBVPMatchReadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordData = [NSMutableData data];
    
    
    
    // MARK: 这里的阈值默认使用60.1
    self.vpClient = [DBVocalPrintClient shareInstance];
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
    
    if (!self.isMatchMore) {
        self.matchInfoLabel.text = [NSString stringWithFormat:@"%@:%@",self.matchName,self.matchId];
        self.threshold = @60.1;
    }else {
        self.threshold = @30.1;
        self.matchInfoLabel.text = @"声纹服务1:N验证";
        self.deleteButton.hidden = YES;
    }
}
- (IBAction)startReadAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    if (button.isSelected) {
        self.voiceImageView.hidden = NO;
        [self resetAudioData];
        [self setupMicrophone];
        [self startReocord];
    }else {
        self.voiceImageView.hidden = YES;
        [self endRecord];
        if (self.isMatchMore) {
            [self matchMoreResult];
        }else {
            [self matchOneResult];
        }
    }
    
}

- (void)matchOneResult {
    [self showHUD];
    [self.vpClient matchOneVPWithAudioModel:[self createMatchOneModel] callBackHandler:^(DBMatchOneVPResponseModel * _Nullable resModel) {
        [self hiddenHUD];
        if ([self responseStateIsSuccess:resModel.err_no]) {
            DBVPMatchSuccessVC *matchResultVC = [[UIStoryboard storyboardWithName:@"DBVPStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"DBVPMatchSuccessVC"];
            matchResultVC.matchName = self.matchName;
            matchResultVC.matchId = self.matchId;
            matchResultVC.score = resModel.score;
            [self.navigationController pushViewController:matchResultVC animated:YES];
        }else {
            [self.view makeToast:resModel.err_msg duration:1.5 position:CSToastPositionCenter];
        }
    }];
}
- (IBAction)deleteVP:(id)sender {
    [self showDeleteHUD];
    [self.vpClient deleteVPWithAccessToken:self.accessToken registerId:self.matchId callBackHandler:^(DBVPResponseModel * _Nullable resModel) {
        [self hiddenHUD];
        NSLog(@"[delete vp] err_msg:%@ traceId:%@",resModel.err_msg,resModel.log_id);
        if ([self responseStateIsSuccess:resModel.err_no]) {
            // 删除本地缓存
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSArray *list = [userDefaults arrayForKey:userMatchId];
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (NSDictionary *dict in list) {
                if (![dict[matchId] isEqualToString:self.matchId]) {
                    [mutableArray addObject:dict];
                }
            }
            [userDefaults setValue:mutableArray forKey:userMatchId];

        }

    }];
}

- (void)matchMoreResult {
    [self showHUD];
    [self.vpClient matchMoreVPWithAudioModel:[self createMatchMoreModel] callBackHandler:^(DBMatchMoreVPResponseModel * _Nullable resModel) {
        [self hiddenHUD];
        if ([self responseStateIsSuccess:resModel.err_no]) {
            DBVPMatchMoreListVC *matchResultVC = [[UIStoryboard storyboardWithName:@"DBVPStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"DBVPMatchMoreListVC"];
            matchResultVC.datasource = resModel.matchList;
//            matchResultVC.matchName = self.matchName;
//            matchResultVC.matchId = self.matchId;
//            matchResultVC.score = resModel.score;
            [self.navigationController pushViewController:matchResultVC animated:YES];
        }else {
            [self.view makeToast:resModel.err_msg duration:1.5 position:CSToastPositionCenter];
        }
    }];
    
}


- (BOOL)responseStateIsSuccess:(NSNumber *)err_on {
    return [err_on.stringValue isEqualToString:@"90000"];
}
- (DBMatchOneAudioModel *)createMatchOneModel {
    DBMatchOneAudioModel *model = [DBMatchOneAudioModel mactchOneAudioModelWithToken:self.accessToken audioData:self.recordData matchId:self.matchId scoreThreshold:self.threshold];
    return model;
}

- (DBMatchMoreAudioModel *)createMatchMoreModel {
    DBMatchMoreAudioModel *model = [DBMatchMoreAudioModel mactchMoreAudioModelWithToken:self.accessToken audioData:self.recordData listNum:@10 scoreThreshold:self.threshold];
    return model;
}
- (void)startReocord {
    [self.microphone startRecord];
}

- (void)endRecord {
    [self.microphone stop];
}

- (void)resetAudioData {
    [self.recordData resetBytesInRange:NSMakeRange(0, self.recordData.length)];
    self.recordData = nil;
    self.recordData = [NSMutableData data];
}

- (void)setupMicrophone {
    self.microphone = [[DBAudioMicrophone alloc] initWithSampleRate:16000 numerOfChannel:1];
    self.microphone.delegate = self;
}

// MARK: 查询声纹状态

- (void)quertVPStatus {
    if (!self.matchId) {
        [self.view makeToast:@"当前没有声纹Id" duration:1.5 position:CSToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    [self.vpClient matchVPStatusWithAccessToken:self.accessToken registerId:self.matchId callBackHandler:^(DBVPStatusResponnseModel * _Nullable resModel) {
        NSLog(@"[query status] err_msg:%@ status:%@",resModel.err_msg,resModel.status);
    }];
}

// MARK: DBAudioMicrophoneDelegate

- (void)audioMicrophone:(DBAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize {
    NSData *data = [NSData dataWithBytes:pcmByte length:byteSize];
    [self.recordData appendData:data];
}

- (void)audioCallBackVoiceGrade:(NSInteger)grade {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"dbValue:%@",@(grade));
        
        NSUInteger volumeDB = grade;
        static NSInteger index = 0;
        index++;
        if (index == 1) {
            index = 0;
        }else {
            return;
        }
        if (volumeDB < 30) {
            self.voiceImageView.image = [UIImage imageNamed:@"1"];
        }else if (volumeDB < 40) {
            self.voiceImageView.image = [UIImage imageNamed:@"2"];
        }else if (volumeDB < 50) {
            self.voiceImageView.image = [UIImage imageNamed:@"3"];
        }else if (volumeDB < 55) {
            self.voiceImageView.image = [UIImage imageNamed:@"4"];
        }else if (volumeDB < 60) {
            self.voiceImageView.image = [UIImage imageNamed:@"5"];
        }else if (volumeDB < 70) {
            self.voiceImageView.image = [UIImage imageNamed:@"6"];
        }else if (volumeDB < 80) {
            self.voiceImageView.image = [UIImage imageNamed:@"7"];
        }else{
            self.voiceImageView.image = [UIImage imageNamed:@"8"];
        }
    });

}

- (void)microphoneonError:(NSInteger)code message:(NSString *)message {
    
}
- (void)showHUD {
    [[XCHudHelper sharedInstance]showHudOnView:self.view caption:@"验证中" image:nil
                                     acitivity:YES autoHideTime:30];
}

- (void)showDeleteHUD {
    [[XCHudHelper sharedInstance]showHudOnView:self.view caption:@"请求中" image:nil
                                     acitivity:YES autoHideTime:30];
}

- (void)hiddenHUD {
    [[XCHudHelper sharedInstance]hideHud];
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
