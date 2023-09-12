//
//  DBASRVC.m
//  DBASRDemo(002)
//
//  Created by linxi on 2021/2/1.
//

#import "DBASRVC.h"
#import "IQKeyboardManager.h"
#import "DBFASRClient.h"
//#import "HXAudioInputView.h"
//#import "UIButton+AudioInputBtn.h"
#import "UIView+Toast.h"
#import "DBLogManager.h"
#import "DBTimeLogerUtil.h"
#import "DBAudioSDKDemo-Swift.h"
#import "DBUserInfoManager.h"

//#error 请填写clientID, clientSecret 信息

@interface DBASRVC ()<UIPickerViewDelegate,UIPickerViewDataSource,DBFASRClientDelegate,DBAsetSettingDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    NSString *_imageName;
}
@property (weak, nonatomic) IBOutlet UITextField *modeTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
@property (weak, nonatomic) IBOutlet UITextView *timeResultTV;

@property (nonatomic, strong) DBFASRClient * asrAudioClient;
// 数据相关
@property(nonatomic,strong)NSArray * pickerArray;

@property(nonatomic,strong)UILongPressGestureRecognizer * longGes;

@property(nonatomic,copy)NSString * traceId;

@end

@implementation DBASRVC


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.pickerArray = @[@"common",@"medicine",@"far-field",@"english",@"自定义场景"];
    [IQKeyboardManager sharedManager].enable = YES;
    self.modeTextField.text = @"common";
    self.modeTextField.delegate = self;
    [self addBorderOfView:self.resultTextView color:[UIColor lightGrayColor]];
    [self addBorderOfView:self.timeResultTV color:[UIColor lightGrayColor]];
    [self clearTimeResultView];
    
    [self addBorderOfView:self.startButton color:[UIColor whiteColor]];

    self.asrAudioClient.delegate = self;
    self.asrAudioClient.sampleRate = DBOneSpeechSampleRate16K;
    self.asrAudioClient.AudioFormat = DBOneSpeechAudioFormatPCM;
    self.asrAudioClient.addPct = YES;
    self.asrAudioClient.domain = @"common";
    [self resumeUserDefault];
    self.asrAudioClient.log = YES;
    
    // TODO: 请在此处设置授权信息
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    [self.asrAudioClient setupClientId:clientId clientSecret:clientSecret];
    
}

- (void)resumeUserDefault {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString * server = [userDefault stringForKey:@"server"];
    if(server.length == 0) {
        server = [self.asrAudioClient currentServerAddress];
        [userDefault setValue:server forKey:@"server"];
    }
    NSInteger mes = [userDefault integerForKey:@"mes"];
    NSInteger mbs = [userDefault integerForKey:@"mbs"];
    BOOL isOnVad = [userDefault boolForKey:@"vad"];
    NSString *version = [userDefault stringForKey:@"version"];
    if(version.length == 0) {
        version = @"1.0";
        [userDefault setValue:version forKey:@"version"];
    }
    [self updateAsrWithServer:server isVad:isOnVad maxEndSilence:mes maxBeginSilence:mbs version:version];
}


-(void)creatPickerView {
    CGFloat width = self.view.frame.size.width;
    UIPickerView  * pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, width, 150)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.backgroundColor = [UIColor whiteColor];
    UIToolbar  *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, width, 44)];
    
    //这个是toolBar上的确定按钮
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    doneButton.title = @"确定";
    //取消按钮
    UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleTouched:)];
    cancleButton.title = @"取消";
    //将取消按钮，一个空白的填充item和一个确定按钮放入toolBar
    [toolBar setItems:[NSArray arrayWithObjects:cancleButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],doneButton, nil]];
}

// MARK: 设置BorderView
- (void)addBorderOfView:(UIView *)view color:(UIColor *)color {
    if (color) {
        view.layer.borderColor = color.CGColor;
    }
    view.layer.borderWidth = 1.f;
    view.layer.cornerRadius = 5.f;
    view.layer.masksToBounds =  YES;
    view.hidden = NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DBASRSettingVC *settingVC = (DBASRSettingVC *)segue.destinationViewController;
    settingVC.delegate = self;
}
#pragma mark -按钮的点击方法---------

- (IBAction)traceIdAction:(id)sender {
    NSLog(@"复制TraceID");
    NSString *myTraceId = self.traceId;
    NSString *traceId = [NSString stringWithFormat:@"复制会话ID成功:%@",myTraceId];
    if (!self.traceId|| self.traceId.length == 0) {
        [self.view makeToast:@"traceId为空" duration:2 position:CSToastPositionCenter];
    }else {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.traceId;
        [self.view makeToast:traceId duration:2 position:CSToastPositionCenter];
    }
}
- (IBAction)startRecordAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
    [self startRecord:button.isSelected];
}

- (void)startRecord:(BOOL)isStart {
    if (isStart) { // 开启录音
        self.resultTextView.text = @"";
        [KTimeUtil logerASRStartTimeWithVendor:@"biaobei_asr"];
        [self.asrAudioClient startOneSpeechASR];
        [self logMessage:@"[debug]:开启一句话识别"];
        [self clearTimeResultView];
        [self appenText:@"点击开始说话按钮"];
    }else { // 结束录音
        [self.asrAudioClient endOneSpeechASR];
        [self logMessage:@"结束一句话识别"];
        [self appenText:@"点击结束说话按钮"];
    }
    self.startButton.selected = isStart;
    self.voiceImageView.hidden = !isStart;
}

#pragma mark -toolBarBarItem的方法
-(void)doneTouched:(UIBarButtonItem *)sender{
//将textField的第一响应取消
    [self.modeTextField resignFirstResponder];
}
-(void)cancleTouched:(UIBarButtonItem *)sender{
//将textField的第一响应取消
    [self.modeTextField resignFirstResponder];
}

// MARK: 音频相关的回调方法
-(void)initializationResult:(BOOL)log {
    if (!log) {
        NSLog(@"token获取失败");
    }else {
        NSLog(@"token获取成功");
    }
}

- (void)onReady {
    NSLog(@"已与后台连接,正式开始识别");
    [self logMessage:@"建立连接成功"];
    [self appenText:@"建立连接成功"];

//    self.messageLabel.hidden = NO;
//    self.messageLabel.text = @"开始识别";
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.messageLabel.text = @"识别中...";
//    });
}


-(void)identifyTheCallback:(NSString *)message sentenceEnd:(BOOL)sentenceEnd {
    NSLog(@"[debug]:message:%@ sentenceEnd:%@",message,@(sentenceEnd));
    self.resultTextView.text = message;
    [self.resultTextView scrollRangeToVisible:NSMakeRange(self.resultTextView.text.length, 1)];
    if (sentenceEnd) {
        self.messageLabel.text = @"识别结束";
        [self appenText:@"识别结束"];
        CFAbsoluteTime time = KTimeUtil.getAsrTotalTime;
        [self appenText:[NSString stringWithFormat:@"消耗时间：%.3f",time]];
        self.voiceImageView.hidden = YES;
        self.startButton.selected = NO;
        
    }else {
        self.messageLabel.text = @"识别中...";
    }
    if (sentenceEnd){
        // TEST:CODE
        /*
        CFAbsoluteTime toTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"ISR Results(json)：%@",  message);
        [KTimeUtil logerAsRText:message];
        [KTimeUtil logerPackageTime];
        */
        
//        if (!self.startButton.isSelected) {
//            [self startRecordAction:self.startButton];
//        } else {
//            self.startButton.selected = NO;
//            [self startRecord:NO];
//        }
    }
}
- (void)onResult:(DBResponseModel *)model {
    NSLog(@"%@",model);
}

- (void)onError:(NSInteger)code message:(NSString *)message {
    NSLog(@"code:%@ message:%@",@(code),message);
    [self showMessage:message];
    self.startButton.selected = NO;
    self.voiceImageView.hidden = YES;
    NSString *errorMsg = [NSString stringWithFormat:@"一句话识别错误 code:%@ message:%@",@(code),message];
    [self logMessage:errorMsg];
    [self appenText:errorMsg];
}

- (void)resultTraceId:(NSString *)traceId {
    self.traceId = traceId;
//    NSString *traceMessage = [NSString stringWithFormat:@"traceId:%@",traceId];
//    [self logMessage:traceMessage];
}


- (void)showMessage:(NSString *)message {
    self.messageLabel.hidden = NO;
    if (!message) {
        message = @"识别结束";
    }
    self.messageLabel.text = message;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.messageLabel.hidden = YES;
        self.messageLabel.text = @"";
    });
}

-(void)dbValues:(NSInteger)db {
    NSUInteger volumeDB = db;
    static NSInteger index = 0;
    index++;
    if (index == 2) {
        index = 0;
    }else {
        return;
    }
    NSString *imageName = @"5";
    if (volumeDB < 30) {
        imageName = @"1";
    }else if (volumeDB < 40) {
        imageName = @"2";
    }else if (volumeDB < 50) {
        imageName = @"3";
    }else if (volumeDB < 55) {
        imageName = @"4";
    }else if (volumeDB < 60) {
        imageName = @"4";
    }else if (volumeDB < 70) {
        imageName = @"5";
    }else if (volumeDB < 80) {
        imageName = @"5";
    }
    
    if (![_imageName isEqualToString:imageName]) {
        [UIView animateWithDuration:0.1 animations:^{
            self.voiceImageView.image = [UIImage imageNamed:imageName];
        }];
        _imageName = imageName;
        DBLog(@"[asr]: imageName:%@",imageName);
    }
    
}

#pragma mark - pickerViewDelegate&dataSource
//返回picker有几列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//返回每列有几行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//数据源
    return [self.pickerArray count];
}
//返回每行显示的内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *item = [self.pickerArray objectAtIndex:row];

    return item;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor systemTealColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
//picker选取某一行执行的方法
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (row == 4) {
        self.modeTextField.text =  @"";
        self.modeTextField.placeholder =  self.pickerArray[row];
        [self.modeTextField becomeFirstResponder];
        return;
    }
    
    self.modeTextField.text =  self.pickerArray[row];
    self.asrAudioClient.domain = self.pickerArray[row];
    
}

// MARK: UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.asrAudioClient.domain = textField.text;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.view makeToast:@"请输入场景模式" duration:2 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}



// MARK: ------- 长语音识别 --------
-(void)longPressGesAction:(UILongPressGestureRecognizer *)gesture {
    //手势状态 //录音状态 再点击，长按 放开取消，点击取消
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"开始识别");
            [self startRecord:YES];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"结束识别");
            [self startRecord:NO];
        }
            break;
            
        case UIGestureRecognizerStateFailed:
            //HXLog(@"长按手势失败");
            break;
        default:
            break;
            
    }
}

- (DBFASRClient *)asrAudioClient {
    if (!_asrAudioClient) {
        _asrAudioClient = [DBFASRClient shareInstance];
    }
    return _asrAudioClient;
}

- (UILongPressGestureRecognizer *)longGes {
    if (!_longGes) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesAction:)];
        _longGes.minimumPressDuration = 0.3;
        _longGes.delegate = self;
    }
    return _longGes;
}

// MARK: DBASRSetting delegate

- (void)updateAsrWithServer:(NSString *)server isVad:(BOOL)isVad maxEndSilence:(NSInteger)maxEndSilence maxBeginSilence:(NSInteger)maxBeginSilence version:(NSString *)version {
    DBFASRClient *asrClient = self.asrAudioClient;
    asrClient.version = version;
    if (server.length > 0) {
       [asrClient setupURL:server];
    }
    if (!isVad) {
        asrClient.enable_vad = NO;
        return;
    }
    asrClient.enable_vad = isVad;
    asrClient.max_end_silence = maxEndSilence;
    asrClient.max_begin_silence = maxBeginSilence;
    DBLog(@"[asr]: update asr info")
}

// MARK: time result Time

- (void)clearTimeResultView {
    UITextView *tv = self.timeResultTV;
    tv.text = @"";
    tv.hidden = YES;
    
}
- (void)appenText:(NSString *)text {
    if (text.length <= 0) {
        return;
    }
    UITextView *tv = self.timeResultTV;
    tv.hidden = false;
    NSString *timeText = self.timeResultTV.text;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    tv.text = [timeText stringByAppendingFormat:@"%@:%@\n",time,text];
    [tv scrollRangeToVisible:NSMakeRange(tv.text.length - 1, 1)];
}


// MARK: 测试代码

-(void)logMessage:(NSString *)message {
    NSLog(@"message:%@",message);
    [DBLogManager saveCriticalSDKRunData:message];
}
    
- (void)testFlightLight {
    NSInteger timeLength = arc4random() %50  + 10;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeLength target:self selector:@selector(handleTimeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    [timer setFireDate:[NSDate distantPast]];
    [self startButton];
}

- (void)handleTimeAction {
    [self startRecord:NO];
    [self startRecord:YES];
}

@end
