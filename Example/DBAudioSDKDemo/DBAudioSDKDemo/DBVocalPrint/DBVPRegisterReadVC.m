//
//  DBVPRegisterReadVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/9.
//

#import "DBVPRegisterReadVC.h"
#import "DBAudioMicrophone.h"
#import "UIView+Toast.h"

NSString * const userMatchId = @"userMatchId";
NSString * const matchId = @"matchId";
NSString * const matchName = @"matchName";

@interface DBVPRegisterReadVC ()<DBAudioMicrophoneDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *readTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *startReadButton;
@property(nonatomic,strong)DBAudioMicrophone * microphone;
@property(nonatomic,strong)NSMutableData * recordData;
@property(nonatomic,strong)NSString * registerId;
@property(nonatomic,copy)NSArray * textArray;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
/// 文本当前的序号
@property(nonatomic,assign)NSInteger textIndex;

@end

@implementation DBVPRegisterReadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textIndex = 0;
    self.textArray = @[
        @"草丛里有一只雪白的小兔子和一只灰色的小老鼠，虽然长相有点儿相似但它们知道对方并不是自己的同类。",
        @"小兔子内心是孤独的，小老鼠也是，两只孤独的小家伙一见如故，在对方身上嗅到一种前所未有既陌生又熟悉的亲切感。",
        @"往后的一段日子它俩日夜黏在一起叽叽喳喳的聊个不停不亦乐乎的。它俩沉醉在二人世界裡忘记了日夜，忘记了种族和身份"
    ];
    [self updateUIWithCurrentIndex];
    self.recordData = [NSMutableData data];
    [self creatVPIDWithHandler:^(DBVPResponseModel * _Nullable resModel) {
        if ([self responseStateIsSuccess:resModel.err_no]) {
            self.registerId = resModel.registerid;
            NSLog(@"创建声纹库成功VPID:%@",resModel.registerid);
        }else {
            NSLog(@"【create vp id 】error:%@",resModel.err_msg);
        }
    }];
}
- (void)creatVPIDWithHandler:(DBResponseHandler)handler {
    [self.vpClient createVPIDWithAccessToken:self.accessToken Handler:handler];
}

- (IBAction)startReadAction:(id)sender {
    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        self.voiceImageView.hidden = NO;
        [self resetAudioData];
        [self setupMicrophone];
        [self startReocord];
    }else {
        [self endRecord];
        self.voiceImageView.hidden = YES;
        [self registerVPRWithHandler:^(DBRegisterVPResponseModel * _Nullable resModel) {
            if ([self responseStateIsSuccess:resModel.err_no]) {
                NSLog(@"提交第一段声纹注册数据成功");
                self.textIndex += 1;
                if (self.textIndex >= self.textArray.count) {
                    if (resModel.suc_num != 3) {
                        [self.view makeToast:@"注册失败次数不足" duration:1.5 position:CSToastPositionCenter];
                        [self popToListVC];
                        return;
                    }
                    [self saveSuccessRegisterInfo];
                    [self showRegisterSuccessAlert];
                    return;
                }
                [self.view makeToast:@"验证成功,请继续～" duration:1.5 position:CSToastPositionCenter];
                [self updateUIWithCurrentIndex];
            }else {
                NSLog(@"[failed ]upload vp audioData:%@",resModel.err_msg);
                [self.view makeToast:resModel.err_msg duration:1.5 position:CSToastPositionCenter];
            }
        }];
    }
}

- (void)showRegisterSuccessAlert {
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"恭喜您" message:@"声纹注册成功，快去体验声纹匹配吧～" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alerVC dismissViewControllerAnimated:YES completion:^{
            [self popToListVC];
        }];
    }];
    [alerVC addAction:action];
    [self.navigationController presentViewController:alerVC animated:YES completion:nil];
}

/// 当前页面注册到的信息添加到本地
- (void)saveSuccessRegisterInfo {
    
    NSDictionary *matchDict = @{
        matchId:self.registerId,
        matchName:self.name
    };
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefaults objectForKey:userMatchId];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    [mutableArray addObject:matchDict];
    [userDefaults setValue:mutableArray forKey:userMatchId];
}

- (void)popToListVC {
    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:vc animated:YES];
}

- (void)updateUIWithCurrentIndex {
    [self updateTitle];
    [self updateReadTextLabel];
}

- (void)updateTitle {
    self.titleLabel.text = [NSString stringWithFormat:@"第%@段/共%@段",@(self.textIndex + 1),@(self.textArray.count)];
    
}

- (void)updateReadTextLabel {
    NSString *readText = self.textArray[self.textIndex];
    self.readTextLabel.text = readText;
}

- (BOOL)responseStateIsSuccess:(NSNumber *)err_on {
    return [err_on.stringValue isEqualToString:@"90000"];
}

- (void)registerVPRWithHandler:(DBRegisterResHandler)handler {
    DBRegisterAudioModel * registerModel = [self createRegistRequestModel];
    [self.vpClient registerVPWithAuidoModel:registerModel callBackHandler:handler];
}

- (DBRegisterAudioModel *)createRegistRequestModel {
    DBRegisterAudioModel *audioModel = [DBRegisterAudioModel registerAudioModelWithToken:self.accessToken audioData:self.recordData registerId:self.registerId name:self.name scoreThreshold:self.threshold];
    return audioModel;
    
}

- (void)startReocord {
    [self.microphone startRecord];
}

- (void)endRecord {
    [self.microphone stop];
}
- (void)setupMicrophone {

    self.microphone = [[DBAudioMicrophone alloc] initWithSampleRate:16000 numerOfChannel:1];
    self.microphone.delegate = self;
}

- (void)resetAudioData {
    [self.recordData resetBytesInRange:NSMakeRange(0, self.recordData.length)];
    self.recordData = nil;
    self.recordData = [NSMutableData data];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
