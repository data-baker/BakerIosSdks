//  DBASRVC.m
//  DBASRDemo(002)
//  Created by linxi on 2021/2/1.
//

#import "DBASRLongVC.h"
#import "IQKeyboardManager.h"
#import "DBFLongASRClient.h"
#import "UIView+Toast.h"
#import "DBLogManager.h"
#import "DBUserInfoManager.h"
#import "DBAudioSDKDemo-Swift.h"
#import "DBTimeLogerUtil.h"


@interface DBASRLongVC ()<UIPickerViewDelegate,UIPickerViewDataSource,DBFASRClientDelegate,DBAsetSettingDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *modeTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;
@property (weak, nonatomic) IBOutlet UITextView *timeResultTV;

@property (nonatomic, strong) DBFLongASRClient * asrAudioClient;
// 数据相关
@property(nonatomic,strong)NSArray * pickerArray;

@property(nonatomic,copy)NSString * lastText;

@property(nonatomic,copy)NSString * traceId;

@property(nonatomic,assign)BOOL  isStart;

/// time inteval
@property(nonatomic,assign)CFTimeInterval timeInteval;

/// first sentence flag
@property(nonatomic,assign)BOOL  firstSentenceFlag;


@end

@implementation DBASRLongVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastText = self.resultTextView.text;
    self.pickerArray = @[@"common",@"medicine",@"far-field",@"english"];
    self.modeTextField.text = @"common";
//    self.modeTextField.text = @"asr-oneshot";
    self.modeTextField.delegate = self;
    [IQKeyboardManager sharedManager].enable = YES;
    [self addBorderOfView:self.resultTextView color:[UIColor lightGrayColor]];
    [self addBorderOfView:self.startButton color:[UIColor whiteColor]];
    [self addBorderOfView:self.timeResultTV color:[UIColor lightGrayColor]];

//    [self creatPickerView];
    
    self.asrAudioClient.delegate = self;
    self.asrAudioClient.sampleRate = DBLongTimeSampleRate16K;
    self.asrAudioClient.AudioFormat = DBLongTimeAudioFormatPCM;
    self.asrAudioClient.addPct = NO;
    self.asrAudioClient.domain = self.modeTextField.text;
    self.asrAudioClient.log = YES;
    
    // TODO: 请在此处设置授权信息
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    [self.asrAudioClient setupClientId:clientId clientSecret:clientSecret];
    self.isStart = NO;
    [self resumeUserDefault];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.asrAudioClient endLongASR];
}


-(void)creatPickerView {
    CGFloat width = self.view.frame.size.width;
    
    UIPickerView  * pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, width, 150)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.backgroundColor = [UIColor whiteColor];
    UIToolbar  *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, width, 44)];
    
    //设置toolBar的样式
    self.modeTextField.inputView = pickerView;
    self.modeTextField.inputAccessoryView = toolBar;
    
    //这个是toolBar上的确定按钮
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    doneButton.title = NSLocalizedString(@"确定", nil);
    //取消按钮
    UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleTouched:)];
    cancleButton.title = NSLocalizedString(@"取消", nil);
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
}
- (void)resumeUserDefault {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString * server = [userDefault stringForKey:@"longServer"];
    if(server.length == 0) {
        server = [self.asrAudioClient currentServerAddress];
        [userDefault setValue:server forKey:@"longServer"];
    }
    NSString *version = [userDefault stringForKey:@"longVersion"];
    if(version.length == 0) {
        version = @"1.0";
        [userDefault setValue:version forKey:@"longVersion"];
    }
    [self updateAserWithLongAsr:server version:version];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@-->prepareForSegue",[self class]);
    DBASRSettingVC *settingVC = segue.destinationViewController;
    settingVC.delegate = self;
    settingVC.isLongAsr = YES;
}

#pragma mark -按钮的点击方法---------

- (IBAction)recordAction:(id)sender {
    UIButton *button = sender;
    button.selected = !button.selected;
    [self startRecord:button.isSelected];
}

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


- (void)startRecord:(BOOL)isStart {
    if (isStart) { // 开启录音
        self.resultTextView.text = @"";
        self.lastText = @"";
        self.timeInteval = CFAbsoluteTimeGetCurrent();
        [KTimeUtil logerASRStartTimeWithVendor:@"biaobei_asr"];
        [self.asrAudioClient startLongASR];
        self.startButton.selected = YES;
        [self clearTimeResultView];
        [self logMessage:@"开始识别"];
        self.firstSentenceFlag = YES;
    }else { // 结束录音
        [self.asrAudioClient endLongASR];
        self.messageLabel.text = @"识别结束";
        self.startButton.selected = NO;
        [self logMessage:@"结束识别"];
    }
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
        // TODO: 开启测试
//        [self testFlightLight];
    }
}

- (void)onReady {
    [self logMessage:@"已与后台连接,正式开始识别"];
    self.messageLabel.hidden = NO;
    self.messageLabel.text = @"开始识别";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.messageLabel.text = @"识别中...";
    });
}


-(void)identifyTheCallback:(NSString *)message sentenceEnd:(BOOL)sentenceEnd {
    NSLog(@"message:%@ sentenceEnd:%@",message,@(sentenceEnd));
     
//    if (self.firstSentenceFlag) {
//        CFTimeInterval absoluteTime =  CFAbsoluteTimeGetCurrent() - self.timeInteval;
//        NSString *firstInstenceTime = [NSString stringWithFormat:@"尾包结束返回时间:%@",@(absoluteTime)];
//        self.firstSentenceFlag = NO;
//        [self logMessage:firstInstenceTime];
//    }
    

    NSString *appendText = [self.lastText stringByAppendingString:[NSString stringWithFormat:@"%@",message]];
    self.resultTextView.text = appendText;
    [self.resultTextView scrollRangeToVisible:NSMakeRange(self.resultTextView.text.length, 1)];
    if (sentenceEnd) {
        self.lastText = [self.lastText stringByAppendingString:message];
        [self appenText:[NSString stringWithFormat:@"消耗时间：%.3f",KTimeUtil.getAsrTotalTime]];
    }
    [self appenText:@"识别中"];
    if (self.startButton.isSelected == NO) {
        self.messageLabel.text = @"识别结束";
    }else {
        self.messageLabel.text = @"识别中...";
    }
}

- (void)onError:(NSInteger)code message:(NSString *)message {
    NSLog(@"code:%@ message:%@",@(code),message);
    
    NSString *errorMsg = [NSString stringWithFormat:@"code:%@,message:%@",@(code),message];
    [self showMessage:errorMsg];
    [self logMessage:errorMsg];
    self.startButton.selected = NO;
    self.voiceImageView.hidden = YES;
}

- (void)resultTraceId:(NSString *)traceId {
    self.traceId = traceId;
}

- (void)showMessage:(NSString *)message {
    self.messageLabel.hidden = NO;
    if (!message) {
        message = @"识别结束";
    }
    self.messageLabel.text = message;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.messageLabel.hidden = YES;
//        self.messageLabel.text = @"";
//    });
}

- (void)onResult:(DBLongResponseModel *)model {
    NSLog(@"%@",model);
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
    self.voiceImageView.image = [UIImage imageNamed:imageName];
    
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

// MARK: DBASRSettingDeleagte

- (void)updateAserWithLongAsr:(NSString *)server version:(NSString *)version {
    self.asrAudioClient.version = version;
    if (server.length == 0) {
        return;
    }
    [self.asrAudioClient setupURL:server];
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

- (DBFLongASRClient *)asrAudioClient {
    if (!_asrAudioClient) {
        _asrAudioClient = [DBFLongASRClient shareInstance];
    }
    return _asrAudioClient;
}

// MARK: 测试代码

-(void)logMessage:(NSString *)message {
    NSLog(@"message:%@",message);
    [DBLogManager saveCriticalSDKRunData:message];
    [self appenText:message];
}
    
- (void)testFlightLight {
    NSInteger timeLength = arc4random() %1800  + 10;
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
