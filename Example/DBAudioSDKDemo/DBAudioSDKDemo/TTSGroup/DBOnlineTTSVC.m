//
//  DBOnlineTTSVC.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/8/3.
//

#import "DBOnlineTTSVC.h"
#import <DBSynthesizerManager.h>
#import "DBUserInfoManager.h"

static NSString * textViewText = @"标贝（北京）科技有限公司，简称：标贝科技。成立于2016年2月，总部位于北京，标贝科技是一家专注于智能语音交互和AI数据服务的人工智能公司，拥有AI语音交互及数据采标处理技术，打造多场景应用的语音交互方案，包括通用场景的语音合成和语音识别，以及TTS音色定制，声音复刻，情感合成和声音转换等语音技术产品；AI数据业务包括语音合成、语音识别、图像视觉、NLP等采标服务和平台化自研工具。";

@interface DBOnlineTTSVC ()<DBSynthesizerManagerDelegate,DBSynthesisPlayerDelegate,UITextViewDelegate>
/// 合成管理类
@property(nonatomic,strong)DBSynthesizerManager * synthesizerManager;
/// 合成需要的参数
@property(nonatomic,strong)DBSynthesizerRequestParam * synthesizerPara;
/// 展示文本的textView
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic,strong)NSMutableString * textString;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
/// 展示回调状态
@property (weak, nonatomic) IBOutlet UITextView *displayTextView;

// 保存测试返回的数据
@property(nonatomic,strong)NSMutableData * resSynthesisData;
@end

@implementation DBOnlineTTSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textString = [textViewText mutableCopy];
    self.resSynthesisData = [NSMutableData data];

    self.displayTextView.text = @"";
    [self addBorderOfView:self.textView];
    [self addBorderOfView:self.displayTextView];
    self.textView.text = textViewText;
    
    _synthesizerManager = [[DBSynthesizerManager alloc]init];
    //设置打印日志
    _synthesizerManager.log = NO;
    _synthesizerManager.delegate = self;
    _synthesizerManager.playerDelegate = self;
    //TODO: 如果使用私有化部署,按如下方式设置URL,否则设置setupClientId：clientSecret：的方法进行授权
//   [_synthesizerManager setupPrivateDeploymentURL:@""];
    // TODO: 请在此处设置授权信息
    NSString *clientId = [DBUserInfoManager shareManager].clientId;
    NSString *clientSecret = [DBUserInfoManager shareManager].clientSecret;
    
    [_synthesizerManager setupClientId:clientId clientSecret:clientSecret handler:^(BOOL ret, NSString *message) {
        if (ret) {
            NSLog(@"鉴权成功");
        }else {
            NSLog(@"鉴权失败");
        }
    }];
    
}
// MARK: IBActions

- (IBAction)startAction:(id)sender {
    // 先清除之前的数据
    [self resetPlayState];
    self.displayTextView.text = @"";
    if (!self.synthesizerPara) {
        self.synthesizerPara = [[DBSynthesizerRequestParam alloc]init];
    }
    self.synthesizerPara.text = self.textView.text;
//    self.synthesizerPara.voice = @"Beiying"; // 四川话模型
//    self.synthesizerPara.language = @"SCH"; // 设置语言为四川话
    self.synthesizerPara.voice = @"Lingling";
    self.synthesizerPara.audioType = DBParamAudioTypePCM8K;
//    self.synthesizerPara.silence = @"0";
//    self.synthesizerPara.spectrum = @"5";
//  self.synthesizerPara.voice = @"Guozi";
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    // 设置合成参数
    NSInteger code = [self.synthesizerManager setSynthesizerParams:self.synthesizerPara];
    if (code == 0) {
        // 开始合成
        [self.synthesizerManager startPlayNeedSpeaker:YES];
    }
    NSLog(@"设置时间 %@",@(CFAbsoluteTimeGetCurrent() - startTime));
}
- (IBAction)closeAction:(id)sender {
    [self.synthesizerManager cancel];
    [self resetPlayState];
    self.displayTextView.text = @"";
    [self.resSynthesisData resetBytesInRange:NSMakeRange(0, self.resSynthesisData.length)];
    self.resSynthesisData = nil;
    self.resSynthesisData = [NSMutableData data];

}
///  重置播放器播放控制状态
- (void)resetPlayState {
    if (self.playButton.isSelected) {
        self.playButton.selected = NO;
    }

}

- (IBAction)playAction:(UIButton *)sender {
    if (self.synthesizerManager.isPlayerPlaying) {
        [self.synthesizerManager pausePlay];
    }else {
        [self.synthesizerManager resumePlay];
    }
}
- (IBAction)currentPlayPosition:(id)sender {
    NSString *position = [NSString stringWithFormat:@"播放进度 %@",[self timeDataWithTimeCount:self.synthesizerManager.currentPlayPosition]];
    [self appendLogMessage:position];
}
- (IBAction)getAudioLength:(id)sender {
    NSString *audioLength = [NSString stringWithFormat:@"音频数据总长度 %@",[self timeDataWithTimeCount:self.synthesizerManager.audioLength]];
    [self appendLogMessage:audioLength];
}
- (IBAction)playState:(id)sender {
    NSString *message;
    if (self.synthesizerManager.isPlayerPlaying) {
        message = @"正在播放";
    }else {
        message = @"播放暂停";
    }
    [self appendLogMessage:message];
}

//

- (void)onSynthesisCompleted {
    [self appendLogMessage:@"合成完成"];
}

- (void)onSynthesisStarted {
//    [self appendLogMessage:@"与服务器连接成功"];
}
/// 合成的第一帧的数据已经得到了
- (void)onPrepared {
    NSLog(@"拿到第一帧数据");
}
- (void)onBinaryReceivedData:(NSData *)data audioType:(NSString *)audioType interval:(NSString *)interval interval_x:(nonnull NSString *)interval_x endFlag:(BOOL)endFlag {
    NSLog(@"interval :%@",interval);
    [self.resSynthesisData appendData:data];
    if (endFlag) {
        NSString *path = [NSString stringWithFormat:@"%@/responseSynthesis.pcm",NSTemporaryDirectory()] ;
        [self.resSynthesisData writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
    }
    [self appendLogMessage:[NSString stringWithFormat:@"收到合成回调的数据endFlag:%@",@(endFlag)]];
}

- (void)onTaskFailed:(DBFailureModel *)failreModel  {
    [self appendLogMessage:[NSString stringWithFormat:@"合成失败 %@",failreModel.message]];
}

//MARK:  UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:textViewText]&&textView == self.textView) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    if (self.displayTextView.isFirstResponder) {
        [self.displayTextView resignFirstResponder];
    }
}

//MARK: player Delegate


- (void)readlyToPlay {
    [self appendLogMessage:@"准备就绪"];
    self.playButton.selected = YES;
}

- (void)playFinished {
    [self appendLogMessage:@"播放结束"];
    [self resetPlayState];
    self.playButton.selected = NO;
}

- (void)playPausedIfNeed {
    self.playButton.selected = NO;
    [self appendLogMessage:@"暂停"];

}

- (void)playResumeIfNeed  {
    self.playButton.selected = YES;
    [self appendLogMessage:@"播放"];
}

- (void)updateBufferPositon:(float)bufferPosition {
    [self appendLogMessage:[NSString stringWithFormat:@"buffer 进度 %.0f%%",bufferPosition*100]];
}
- (void)playerFaiure:(NSString *)errorStr {
    [self appendLogMessage:[NSString stringWithFormat:@"播放器出错:%@",errorStr]];
}

// MARK: Private Methods

- (void)addBorderOfView:(UIView *)view {
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 1.f;
    view.layer.masksToBounds =  YES;
}




- (NSString *)timeDataWithTimeCount:(CGFloat)timeCount {
    long audioCurrent = ceil(timeCount);
    NSString *str = nil;
    if (audioCurrent < 3600) {
        str =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(audioCurrent/60.f)),lround(floor(audioCurrent/1.f))%60];
    } else {
        str =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(audioCurrent/3600.f)),lround(floor(audioCurrent%3600)/60.f),lround(floor(audioCurrent/1.f))%60];
    }
    return str;
    
}

- (void)appendLogMessage:(NSString *)message {
    NSString *text = self.displayTextView.text;
    NSString *appendText = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@",message]];
    self.displayTextView.text = appendText;
    [self.displayTextView scrollRangeToVisible:NSMakeRange(self.displayTextView.text.length, 1)];
}


@end
