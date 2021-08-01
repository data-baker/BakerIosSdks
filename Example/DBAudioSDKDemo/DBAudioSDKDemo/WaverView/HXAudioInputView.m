//
//  AudioInputView.m
//  HXWaverView
//
//  Created by ghx on 2020/5/22.
//  Copyright © 2020 Catch Inc. All rights reserved.
//

#import "HXAudioInputView.h"

#import <AVFoundation/AVFoundation.h>

#import "HXWaverView.h"

#import <Masonry.h>
#import <FrameAccessor/FrameAccessor.h>


#ifdef DEBUG
#define HXLog(...) NSLog(__VA_ARGS__)
#else
#define HXLog(...)
#endif

@interface HXAudioInputView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, strong) UIButton * longPressBtn; //底部按钮
@property (nonatomic, assign) CGFloat shortPressTime; //短按时间 默认最大 0.3

@property (nonatomic, strong) UIView * shadowView;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) HXWaverView * waver;    //波纹

@property (nonatomic, strong) UIButton * closeBtn;
@property (nonatomic, strong) UILabel * titleDesLab;
@property (nonatomic, strong) UILabel * waitDesLab;

//删除
@property (nonatomic, strong) UIImageView * deleteIconV;
@property (nonatomic, strong) UILabel * deleteDesLab;


@property (nonatomic, strong) UILongPressGestureRecognizer * longGes;
@property (nonatomic, strong) UITapGestureRecognizer * tapGes;

@property (nonatomic, assign) HXAudioInputViewType inputeType;

@property (nonatomic, copy) AudioBeginBlk beginBlk;
@property (nonatomic, copy) AudioEndBlk endBlk;
@property (nonatomic, copy) AudioCancelBlk cancelBlk;



@property (nonatomic, assign) int currLevel;

@property (nonatomic, assign) BOOL isCompleteOp;

@property (nonatomic, strong) UIColor * btnLightColor; //按钮点击颜色
@property (nonatomic, strong) UIColor * btnDefaultColor; //按钮普通颜色
@property (nonatomic, strong) UIColor * waverColor; //声波颜色
@end

@implementation HXAudioInputView

#pragma mark- Public Method
+ (instancetype)shareInstance {
    static HXAudioInputView * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HXAudioInputView alloc] initUniqueInstance];
        instance.endInputDismiss = YES;
    });
    return instance;
}

-(instancetype)initUniqueInstance {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)reLisheningFail:(BOOL)noResult {
    self.inputeType = HXAudioInputViewWaitType;
    if (noResult) {
        _titleDesLab.text = @"抱歉没听清，试着说" ;
    }
    self.isCompleteOp = NO;
    self.bgView.hidden = NO;
}

- (void)beginLisheningWithShowType:(HXAudioInputViewShowType)showType {
    
    if (showType == HXAudioInputViewShowTypeListen) {
        //点击开始，点击取消
        self.inputeType = HXAudioInputViewSayingType;
        self.isCompleteOp= NO;
        if (self.beginBlk) {
            self.beginBlk();
        }
        
    } else if (showType == HXAudioInputViewShowTypePressListhen) {
        //长按开始，松开结束
        self.inputeType = HXAudioInputViewPressSayingType;
        self.isCompleteOp= NO;
        if (self.beginBlk) {
            self.beginBlk();
        }
        
    } else {
        //初始等待状态
        self.inputeType = HXAudioInputViewWaitType;
        self.isCompleteOp= NO;
      
    }
    
}

- (void)endListhening {
    
    [self dismissView];
    self.inputeType = HXAudioInputViewWaitType;
    self.isCompleteOp= YES;
    
    if (self.endBlk) {
        self.endBlk();
    }
}

- (void)dismissView {
    if (self.endInputDismiss) {
        self.bgView.hidden = YES;
        self.shadowView.alpha =0;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setVoiceLevel:(int)level {
    
    self.currLevel = level;
}

- (BOOL)canSearch {
    //结果完成 或者 当前监听状态
    if (self.isCompleteOp) {
        return YES;
    }
    if (self.inputeType == HXAudioInputViewSayingType) {
        return YES;
    }
    return NO;
}

- (void)showInController:(UIViewController *)vc {
    if (vc) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [vc presentViewController:self animated:YES completion:nil];
    } else {
        if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController == nil)
        {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:NO completion:nil];
        }
    }
}

- (void)defaultSetting {
    self.btnLightColor = [UIColor colorWithRed:62.0/255.0 green:127.0/255.0 blue:250.0/255.0 alpha:1];
       self.btnDefaultColor = [UIColor colorWithRed:52.0/255.0 green:113.0/255.0 blue:228.0/255.0 alpha:1];
       self.waverColor = self.btnLightColor;
       if (self.shortPressTime == 0) {
           self.shortPressTime = 0.3;
       }
        self.inputeType = HXAudioInputViewWaitType;
}

#pragma mark- cycle life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self defaultSetting];
    [self createUI];
    _bgView.userInteractionEnabled = YES;
    _longPressBtn.userInteractionEnabled = YES;
    [self setupRecorder];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.shadowView .alpha = 0.2;
    }];
    
    self.bgView.hidden = NO;
    self.bgView.bottom = self.bgView.bottom + self.bgView.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.bottom = self.view.bottom;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- initUI
- (void)createUI {
    
    //    [self setupRecorder];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //这个可以写在viewDidLoad里面
    self.shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.shadowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.shadowView];
    //在present的之前,先
    self.shadowView .alpha = 0.0;
    UITapGestureRecognizer * tagShadowGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowTap:)];
    [self.shadowView addGestureRecognizer:tagShadowGes];
    
    
    [self.view addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.offset(0);
        make.height.mas_equalTo(252);
    }];
    
    //关闭按钮
    [self.bgView addSubview:self.closeBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(30);
        make.top.offset(15);
        make.right.offset(-15);
    }];
    
    //标题
    [self.bgView addSubview:self.titleDesLab];
    [_titleDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.right.offset(-15);
        make.left.offset(15);
    }];
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.bgView addSubview:self.waver];
    [_waver mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.mas_equalTo(20);
        make.center.offset(0);
    }];
    
    //波纹
    _waver.waverLevelCallback = ^(HXWaverView * waver) {
        
        if (weakSelf.audioLevelOutSide) {
            if (weakSelf.currLevel < 2) {
                weakSelf.currLevel = 2;
            }
            waver.level = weakSelf.currLevel/10.000;
        } else {
            [weakSelf.recorder updateMeters];
            CGFloat normalizedValue = pow (10, [weakSelf.recorder averagePowerForChannel:0] / 40);
            waver.level = normalizedValue;
        }

    };
    
    
    //底部按钮
    [self.bgView addSubview:self.longPressBtn];
    [_longPressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.left.offset(15);
        make.right.offset(-15);
        make.bottom.offset(-24);
    }];

    [_longPressBtn addGestureRecognizer:self.longGes];
    [_longPressBtn addGestureRecognizer:self.tapGes];
    [self.tapGes requireGestureRecognizerToFail:self.longGes];
    
    //描述
    [self.bgView addSubview:self.waitDesLab];
    [_waitDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleDesLab.mas_bottom).offset(10);
        make.bottom.equalTo(self.longPressBtn.mas_top).offset(-10);
        make.right.offset(-15);
        make.left.offset(15);
    }];
    
    
    
    //删除图标
    [self.bgView addSubview:self.deleteIconV];
    [_deleteIconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(38);
        make.centerX.offset(0);
        make.bottom.equalTo(self.bgView.mas_centerY).offset(-20);
    }];
    
    //删除描述
    [self.bgView addSubview:self.deleteDesLab];
    [_deleteDesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.bgView.mas_centerY).offset(0);
    }];
    
    
    [self.view layoutIfNeeded];
    //背景特定圆角
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bgView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.bgView.layer.mask = maskLayer;
    
    
    self.bgView.hidden = YES;
}

-(void)setupRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat:44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
    
}

#pragma mark- Event
- (void)shadowTap:(UIGestureRecognizer *)ges {
    self.shadowView.alpha =0;
    [self dismissViewControllerAnimated:YES completion:nil];
    self.inputeType = HXAudioInputViewWaitType;
    
    self.isCompleteOp= YES;
    self.bgView.hidden = YES;
    if(self.cancelBlk){
        self.cancelBlk();
    }
}

- (void)beginAction {
    self.isCompleteOp= NO;
    if (self.beginBlk) {
        self.beginBlk();
    }
}

- (void)closeAction {
   
    self.bgView.hidden = YES;
    self.shadowView.alpha =0;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.inputeType = HXAudioInputViewWaitType;
    
    self.isCompleteOp= YES;
    
    if(self.cancelBlk){
        self.cancelBlk();
    }
    
}

- (void)endAction {
    
    [self dismissView];
    self.inputeType = HXAudioInputViewWaitType;
    
    self.isCompleteOp= YES;
    if (self.endBlk) {
        self.endBlk();
    }
}

#pragma mark- GestureRecopngnizer
-(void)tapGesAction:(UITapGestureRecognizer *)gesture
{
    NSLog(@"");
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
           
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            
            if (self.inputeType == HXAudioInputViewWaitType) {
                
                self.inputeType = HXAudioInputViewSayingType;
                [self beginAction];
                
            }
            else  if (self.inputeType == HXAudioInputViewSayingType) {
                //按住放开取消

                self.inputeType = HXAudioInputViewWaitType;
                [self endAction];
                
            }
        

        }
            break;
            
        case UIGestureRecognizerStateFailed:
            //HXLog(@"长按手势失败");
            
            break;
            
        default:
            
            break;
            
    }
}
-(void)longPressGesAction:(UILongPressGestureRecognizer *)gesture
{
    
    int sendState = 0; //是否划开
    CGPoint  point = [gesture locationInView:self.longPressBtn];
    
    if (point.y<0)
    {
        
        HXLog(@"松开手指，取消发送");
        sendState = 1;
        self.inputeType = HXAudioInputViewDeletingType;
        
    }
    else
    {
        //重新进入录音范围内
        sendState = 0;
        //            HXLog(@"重新进入录音范围内");
        if (self.inputeType == HXAudioInputViewDeletingType) {
            HXLog(@"撤销上滑取消操作");
            self.inputeType = HXAudioInputViewTouchUpFinishType;
        }
    }
    
    //手势状态 //录音状态 再点击，长按 放开取消，点击取消
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
    
            if (!sendState) {
               
                if (self.inputeType == HXAudioInputViewSayingType) {
                    //按住放开取消
                    self.inputeType = HXAudioInputViewTouchUpFinishType;
                }
                if (self.inputeType == HXAudioInputViewWaitType) {
                    //按住放开取消
                    self.inputeType = HXAudioInputViewPressSayingType;
                    
                    [self beginAction];
                    
                }
            }
            
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            
            
            //HXLog(@"长按手势结束");
            if (sendState == 0)
            {
                
                //录音状态 再点击，长按 放开取消，点击取消
                if (self.inputeType == HXAudioInputViewTouchUpFinishType) {
                    [self endAction];
                    
                } else if (self.inputeType == HXAudioInputViewPressSayingType) {
    
                    [self endAction];
                    
                }
            }
            else
            {
                //向上滑动取消发送
                HXLog(@"取消发送删除录音");
                [self closeAction];
            }
            
            
        }
            break;
            
        case UIGestureRecognizerStateFailed:
            //HXLog(@"长按手势失败");
            
            break;
            
        default:
            
            break;
            
    }
    
}
#pragma mark - Setting


- (void)setBeginBlk:(AudioBeginBlk)beginBlk endBlk:(AudioEndBlk)endBlk cancelBlk:(AudioCancelBlk)cancelBlk {
    self.beginBlk = beginBlk;
    self.endBlk = endBlk;
    self.cancelBlk = cancelBlk;
}

- (void)setInputeType:(HXAudioInputViewType)inputeType {
    _inputeType = inputeType;
    switch (inputeType) {
        case HXAudioInputViewWaitType:
        {
            _titleDesLab.text = @"我是你的XXX" ;
            [self setText:@"XXXX" lab:_waitDesLab];
            
            _titleDesLab.hidden = NO;
            _waitDesLab.hidden = NO;
            
            _waver.hidden = YES;
            
            _deleteDesLab.hidden = YES;
            _deleteIconV.hidden = YES;
            
            
        }
            break;
            
        case HXAudioInputViewPressSayingType:
        {
            _titleDesLab.text = @"XXX正在聆听";
            _waitDesLab.text = @"";
            
            _titleDesLab.hidden = NO;
            _waitDesLab.hidden = NO;
            _waver.hidden = NO;
            
            _deleteDesLab.hidden = YES;
            _deleteIconV.hidden = YES;
        }
            break;
            
        case HXAudioInputViewDeletingType:
        {
            _deleteDesLab.text = @"松开手指，取消搜索";
            
            
            
            _titleDesLab.hidden = YES;
            _waitDesLab.hidden = YES;
            _waver.hidden = YES;
            
            _deleteDesLab.hidden = NO;
            _deleteIconV.hidden = NO;
        }
            break;
            
        case HXAudioInputViewSayingType:
        {
            
            
            _titleDesLab.text = @"正在聆听";
            _deleteDesLab.hidden = YES;
            _titleDesLab.hidden = NO;
            _waitDesLab.hidden = YES;
            _waver.hidden = NO;
            
            _deleteDesLab.hidden = YES;
            _deleteIconV.hidden = YES;
        }
            break;
        case HXAudioInputViewTouchUpFinishType:
        {
            _titleDesLab.text = @"正在聆听";
            _deleteDesLab.hidden = YES;
            
            _titleDesLab.hidden = NO;
            _waitDesLab.hidden = YES;
            _waver.hidden = NO;
            
            _deleteDesLab.hidden = YES;
            _deleteIconV.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
    [self setLongPressBtnTitleAndBgWithAudioType:inputeType];
}

- (void)setLongPressBtnTitleAndBgWithAudioType:(HXAudioInputViewType)type {
    
    switch (type) {
        case HXAudioInputViewWaitType:
        {
            [_longPressBtn setBackgroundColor:self.btnDefaultColor];
            [_longPressBtn setTitle:@"点击或长按说话" forState:UIControlStateNormal];
            
        }
            break;
            
        case HXAudioInputViewPressSayingType:
        {
            [_longPressBtn setBackgroundColor:self.btnLightColor];
            [_longPressBtn setTitle:@"松开结束" forState:UIControlStateNormal];
            
            
        }
            break;
            
        case HXAudioInputViewDeletingType:
        {
            [_longPressBtn setBackgroundColor:self.btnLightColor];
            [_longPressBtn setTitle:@"松开手指 取消搜索" forState:UIControlStateNormal];
        }
            break;
            
        case HXAudioInputViewSayingType:
        {
            [_longPressBtn setBackgroundColor:self.btnDefaultColor];
            [_longPressBtn setTitle:@"点击停止收听" forState:UIControlStateNormal];
        }
            break;
            
        case HXAudioInputViewTouchUpFinishType:
        {
            [_longPressBtn setBackgroundColor:self.btnLightColor];
            [_longPressBtn setTitle:@"松开结束" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)setWaverColor:(UIColor *)waverColor {
    _waverColor = waverColor;
    _waver.waveColor = waverColor;
}

#pragma mark- Getting
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        
    }
    return _bgView;
}


- (HXWaverView *)waver {
    if (!_waver) {
        _waver = [[HXWaverView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)/2.0 - 50.0, CGRectGetWidth(self.view.bounds), 50.0)];
        _waver.waveColor = self.waverColor;
        _waver.numberOfWaves = 4;
    }
    return _waver;
}



- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[UIImage imageNamed:@"AudioInputClose"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}


- (UILabel *)titleDesLab {
    if (!_titleDesLab) {
        _titleDesLab = [[UILabel alloc] init];
        _titleDesLab.textAlignment = NSTextAlignmentCenter;
        _titleDesLab.numberOfLines = 0;
        _titleDesLab.textColor = [UIColor lightGrayColor];
        _titleDesLab.font = [UIFont systemFontOfSize:18];
    }
    return _titleDesLab;
}


- (UILabel *)waitDesLab {
    if (!_waitDesLab) {
        _waitDesLab = [[UILabel alloc] init];
        _waitDesLab.textAlignment = NSTextAlignmentCenter;
        _waitDesLab.numberOfLines = 0;
        _waitDesLab.textColor = [UIColor lightGrayColor];
        _waitDesLab.font = [UIFont systemFontOfSize:15];
    }
    return _waitDesLab;
}




- (UIButton *)longPressBtn {
    if (!_longPressBtn) {
        _longPressBtn = [[UIButton alloc] init];
        _longPressBtn.layer.cornerRadius = 5;
        _longPressBtn.clipsToBounds = YES;
        _longPressBtn.multipleTouchEnabled = YES;
    }
    return _longPressBtn;
}


- (UIImageView *)deleteIconV {
    if (!_deleteIconV) {
        _deleteIconV = [[UIImageView alloc] init];
        _deleteIconV.image = [UIImage imageNamed:@"AudioInputDelete"];
    }
    return _deleteIconV;
}


- (UILabel *)deleteDesLab {
    if (!_deleteDesLab) {
        _deleteDesLab = [[UILabel alloc] init];
        _deleteDesLab.textAlignment = NSTextAlignmentCenter;
        _deleteDesLab.textColor = [UIColor lightGrayColor];
        _deleteDesLab.font = [UIFont systemFontOfSize:15];
    }
    return _deleteDesLab;
}



- (UILongPressGestureRecognizer *)longGes {
    if (!_longGes) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesAction:)];
        _longGes.minimumPressDuration = self.shortPressTime;
        _longGes.delegate = self;
    }
    return _longGes;
}
- (UITapGestureRecognizer *)tapGes {
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)];
        _tapGes.delegate = self;
    }
    return _tapGes;
}


#pragma mark- Other

/// 设置文字内容的行间距
/// @param text 内容
/// @param lab 文本控件
- (void)setText:(NSString *)text lab:(UILabel *)lab {
    NSString * str = text;
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [attStr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, str.length)];
    lab.attributedText = attStr;
}

#pragma mark- Auth
+ (BOOL)authForListhenStatus {
    
    AVAuthorizationStatus microPhoneStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (microPhoneStatus) {
        case AVAuthorizationStatusDenied: {
            return NO;
        }
        case AVAuthorizationStatusRestricted:
        {
            // 被拒绝
            [self goMicroPhoneSet];
            return NO;
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            // 没弹窗
            [self requestMicroPhoneAuth];
            return NO;
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            // 有授权
            return YES;
        }
            break;
            
        default:
            return NO;
            break;
    }
    
}



+ (void)requestMicroPhoneAuth
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
}

+ (void)goMicroPhoneSet
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"您没有使用麦克风的权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:url options:nil completionHandler:^(BOOL success) {
                
            }];
        });
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:setAction];
    
    [AudioInputViewCurrVC() presentViewController:alert animated:YES completion:nil];
}


///获取当前活动的控制器
NS_INLINE UIViewController * AudioInputViewFindBestViewController(UIViewController* vc);
NS_INLINE UIViewController * AudioInputViewCurrVC(void) {
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return AudioInputViewFindBestViewController(viewController);
    
}

NS_INLINE UIViewController * AudioInputViewFindBestViewController(UIViewController* vc) {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return AudioInputViewFindBestViewController(vc.presentedViewController);
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return AudioInputViewFindBestViewController(svc.viewControllers.lastObject);
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return AudioInputViewFindBestViewController(svc.topViewController);
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return AudioInputViewFindBestViewController(svc.selectedViewController);
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}


@end
