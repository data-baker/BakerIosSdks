//
//  DBOfflineVoiceConvertVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/10/25.
//

#import "DBOfflineVoiceConvertVC.h"
#import "DBOfflineVCKit.framework/Headers/DBOfflineConvertVoiceClient.h"
#import "DBUserInfoManager.h"
#import "UIView+Toast.h"

@interface DBOfflineVoiceConvertVC ()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate,DBOfflineVoiceConvertDelegate>
@property (weak, nonatomic) IBOutlet UILabel *subTitlelabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *voiceTextField;
@property (weak, nonatomic) IBOutlet UIButton *startTransferButton;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImageView;

/// 声音转换的client
@property(nonatomic,strong)DBOfflineConvertVoiceClient * convertClient;

// 数据相关
@property(nonatomic,strong)NSArray * pickerArray;

@property(nonatomic,strong)UILongPressGestureRecognizer * longGes;

@property(nonatomic,strong)NSDictionary * voiceNamaDictionary;

@end

@implementation DBOfflineVoiceConvertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.convertClient = [DBOfflineConvertVoiceClient shareInstance];
    self.convertClient.delegate = self;
    self.convertClient.log = YES;
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    [self.convertClient setupVoiceConvertSDKClientId:clientId clientSecret:clientSecret messageHander:^(NSInteger ret, NSString * _Nonnull message) {
        if (ret == 0) {
            NSLog(@"鉴权成功");
        }else {
            NSLog(@"鉴权失败-code:%@-msg:%@",@(ret),message);
        }
    }];
    [self createSubview];
    self.voiceTextField.text = @"萝莉";
    [self.startTransferButton addGestureRecognizer:self.longGes];
    
    //    self.pickerArray = [NSMutableArray array];
    /*
     萝莉    Vc_luoli    16K
     大叔    Vc_dashu    16K
     搞怪    Vc_gaoguai    16K
     空灵    Vc_kongling    16K
     霸王龙    Vc_bawanglong    16K
     重金属    Vc_zhongjinshu    16K
     */
    
    NSDictionary *dict = @{@"萝莉":@"Vc_luoli",
                           @"大叔":@"Vc_dashu",
                           @"搞怪":@"Vc_gaoguai",
                           @"空灵":@"Vc_kongling",
                           @"霸王龙":@"Vc_bawanglong",
                           @"重金属":@"Vc_zhongjinshu",
    };
    self.voiceNamaDictionary = dict;
    self.pickerArray = @[@"萝莉",@"大叔",@"搞怪",@"空灵",@"霸王龙",@"重金属"];
    NSString *voiceNameZH = [self.pickerArray firstObject];
    [self.convertClient setupVoiceName:self.voiceNamaDictionary[voiceNameZH]];
    [self creatPickerView];
    
    // MARK: TEST Code
    
    [self testCode];
}

-(void)createSubview {
    [self addBorderOfView:self.backView color:[UIColor lightGrayColor]];
    self.subTitlelabel.text = [NSString stringWithFormat:@"长按按钮开始说话 \n松开停止说话 \n可选择变声效果"];
    
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

- (void)startRecord:(BOOL)isStart {
    if (isStart) {
        self.voiceImageView.hidden = NO;
        [self.convertClient startAndRecord];
    }else {
        self.voiceImageView.hidden = YES;
        [self.convertClient stopRecord];
    }
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
    //toolbar.barStyle = UIBarStyleDefault;
    
    /***必要步骤****/
    self.voiceTextField.inputView = pickerView;
    self.voiceTextField.inputAccessoryView = toolBar;
    
    //这个是toolBar上的确定按钮
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    doneButton.title = @"确定";
    //取消按钮
    UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleTouched:)];
    cancleButton.title = @"取消";
    //将取消按钮，一个空白的填充item和一个确定按钮放入toolBar
    [toolBar setItems:[NSArray arrayWithObjects:cancleButton,[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],doneButton, nil]];
}




#pragma mark -toolBarBarItem的方法
-(void)doneTouched:(UIBarButtonItem *)sender{
//将textField的第一响应取消
    [self.voiceTextField resignFirstResponder];
    /// 获取原始音频，然后再次调用离线转换
    NSString *pcmPath = [self.convertClient getOriginRecordFile];
    [self.convertClient startFileConvertPCMPath:pcmPath];

}
-(void)cancleTouched:(UIBarButtonItem *)sender{
 
//将textField的第一响应取消
    [self.voiceTextField resignFirstResponder];
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
    NSString *voiceNameZH = self.pickerArray[row];
    self.voiceTextField.text =  voiceNameZH;
    [self.convertClient setupVoiceName:self.voiceNamaDictionary[voiceNameZH]];
}

// Mark: 合成的相关转换
- (void)onError:(NSString *)errorCode msg:(NSString *)message {
    [self.view makeToast:message duration:1.5 position:CSToastPositionCenter];
}
- (void)onReadyForConvert {
    NSLog(@"[call back]开始声音转换");
}

- (void)onConvertComplete {
    NSLog(@"[call back] 转换完成了");
    [self.convertClient play];
}
- (void)onPlayCompleted {
    NSLog(@"[call back]播放完成了");
}

- (void)onPaused {
    NSLog(@"[call back]暂停了");
}
- (void)onStopped {
    NSLog(@"[call back]结束了");
}
- (void)onPlaying {
    NSLog(@"[call back]开始播放了");
//    [self.convertClient pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.convertClient play];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.convertClient stopPlay];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.convertClient play];
    });
}
- (void)onResultData:(NSData *)data endflag:(BOOL)endFlag {
    NSLog(@"收到回传的数据：%@， flag:%@",@(data.length),@(endFlag));
}

// MARK: 麦克风相关的回调
- (void)dbValues:(NSInteger)db {
    NSUInteger volumeDB = db;
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
}

- (UILongPressGestureRecognizer *)longGes {
    if (!_longGes) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesAction:)];
        _longGes.minimumPressDuration = 0.3;
        _longGes.delegate = self;
    }
    return _longGes;
}


- (void)testCode {
    NSString *audioPath = [self.convertClient getOriginRecordFile];
    NSLog(@"[audio Path]:%@",audioPath);
    NSString *convertPath = [self.convertClient getConvertResultFile];
    NSLog(@"[convert audio:%@",convertPath);
}
@end
