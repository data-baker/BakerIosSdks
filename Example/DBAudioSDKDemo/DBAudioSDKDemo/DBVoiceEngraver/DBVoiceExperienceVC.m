//
//  DBVoiceExperienceVC.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceExperienceVC.h"
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
#import "XCHudHelper.h"
#import "UIView+Toast.h"



NSString *const ttsIPURL      = @"https://openapi.data-baker.com/tts_hot_load";

static NSString *textPlaceHolder = @"请输入要合成的文本";

@interface DBVoiceExperienceVC ()<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *playTextView;
@property (weak, nonatomic) IBOutlet UILabel *wordNumLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) AVPlayer * player;
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)NSObject * timeObserve;

@end

@implementation DBVoiceExperienceVC

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.player.rate != 0) {
        [self.player pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [NSString stringWithFormat:@"模型：%@",self.voiceModel.modelId];
    [self p_addPasteActionofView:self.titleLabel];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addBorderOfView:self.playTextView];
    self.playTextView.text = textPlaceHolder;
    self.wordNumLabel.text = @"字数：0/200";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.playButton addTarget:self action:@selector(handlePlayAction:) forControlEvents:UIControlEventTouchUpInside];

}


- (void)appResignActive:(NSNotification *)noti {
    NSLog(@"app 变得不活跃");
    
}
- (void)appBecomeActive:(NSNotification *)noti {
    NSLog(@"app 变活跃");
}
- (IBAction)handlePlayTTSAction:(id)sender {
    [self handlePlayAction:nil];
}

- (void)handlePlayAction:(UIButton *) sender {

    if ([self.playTextView.text isEqualToString:textPlaceHolder]) {
        [self.view makeToast:textPlaceHolder duration:2 position:CSToastPositionCenter];
        return ;
    }
    
    if ([self.voiceModel.modelStatus intValue] != 6) {
        [self.view makeToast:@"请训练成功后再试" duration:2 position:CSToastPositionCenter];

        return;
    }
    
    NSURL *url = [self playWithText:self.playTextView.text];
    [self downloadWithUrl:url completeHandler:^(BOOL ret, NSString * _Nullable msg) {
        if (!ret) {
            [self.view makeToast:msg duration:2.f position:CSToastPositionCenter];
            return;
        }
        [self playMusic];
    }];
}


- (void)downloadWithUrl:(NSURL *)url completeHandler:(BBCompleteHandler)completeHanlder {
    
    NSString *filename = @"xxx.mp3";
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTak = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        
        NSString *savePath = [cachePath stringByAppendingPathComponent:filename];
        NSLog(@"%@",savePath);
        
        NSURL *saveurl = [NSURL fileURLWithPath:savePath];
        NSError *saveError;
        NSFileManager *fileManager =   [NSFileManager defaultManager];
        BOOL exists = [fileManager fileExistsAtPath:savePath];
        if (exists) {
            [fileManager removeItemAtURL:saveurl error:&error];
        }
        [[NSFileManager defaultManager]moveItemAtURL:location toURL:saveurl error:&saveError];
        
        if (saveError) {
            NSLog(@"%@",saveError.localizedDescription);
        }
        if (saveError) {
            NSLog(@"%@",saveError.localizedDescription);
            completeHanlder(NO,saveError.localizedDescription);
        }else {
            completeHanlder(YES,savePath);
        }
    }];
    //执行任务
    [downloadTak resume];
}
-(void)playMusic {
    //获取缓存目录
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"xxx.mp3"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    //判断文件存不存在
    if(
       [[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        NSLog(@"exist");
        NSError *error;
       [self playWithUrl:fileUrl];
        if (error) {
        NSLog(@"%@",error.localizedDescription);
        }
    }
}

- (NSURL *)playWithText:(NSString *)playText {
    NSString *accesstoken = [DBVoiceEngraverManager sharedInstance].accessToken;
    NSString * path = [NSString stringWithFormat:@"%@?access_token=%@&domain=1&language=zh&voice_name=%@&text=%@",ttsIPURL,accesstoken,self.voiceModel.modelId,playText];
    NSString *encodeString = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL * url = [NSURL URLWithString:encodeString];
    return url;
}

- (void)downloadURL {
}

- (void)dealloc {
    if (_timeObserve) {
        [_player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playItem removeObserver:self forKeyPath:@"status"];
}

- (void)playWithUrl:(NSURL *)url {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [self releasePlayItem];
    self.playItem  = [[AVPlayerItem alloc]initWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playItem];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
    NSLog(@"2");
    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)releasePlayItem {
    if (self.playItem) {
        [self.playItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.playItem = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        [self moniPlayBackAction];
        [self.player play];
        NSLog(@"3");
    }
    
}


- (void)moniPlayBackAction {
    __weak typeof(self)weakSelf = self;
 self.timeObserve =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                queue:NULL
                                                          usingBlock:^(CMTime time) {
     
      CGFloat  totalTime = self.playTextView.text.length *0.265;
     
     CGFloat progress = CMTimeGetSeconds(weakSelf.playItem.currentTime) / totalTime;
     
     NSLog(@"progress : %f  currntTime: %f totalTime %f",progress,CMTimeGetSeconds(weakSelf.playItem.currentTime),CMTimeGetSeconds(weakSelf.playItem.duration));
     weakSelf.progressView.progress = progress;
     weakSelf.playSlider.value = progress;
 }];
}

- (void)videoPlayEnd {
    self.playButton.selected = NO;
    self.playSlider.value = 0;
    self.progressView.progress = 0;
}

- (void)addBorderOfView:(UIView *)view {
    view.layer.borderColor = [UIColor systemBlueColor].CGColor;
    view.layer.borderWidth = 1.f;
    view.layer.masksToBounds =  YES;
}
// MARK: UITextView Methods
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:textPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
         [self updataTextCountWithTextLength:textView.text.length];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([text isEqualToString:@""]) {
        NSInteger textLength = textView.text.length -1;
        if (textLength<0) {
            textLength = 0;
        }
        [self updataTextCountWithTextLength:textLength];
        return YES;
    }
    if (textView.text.length + text.length > 200 ) {
        [self.view makeToast:@"最多输入200个文字" duration:2.f position:CSToastPositionCenter];
        return NO;
    }
    [self updataTextCountWithTextLength:textView.text.length + text.length];
    return YES;
}

- (void)updataTextCountWithTextLength:(NSInteger )textLength {
    NSString *subText = [NSString stringWithFormat:@"%@",@(textLength)];
    NSString *allText = [NSString stringWithFormat:@"字数：%ld/200",(long)textLength];
    NSAttributedString *attributeString = [self setupCountLabelText:allText attributeText:subText];
    self.wordNumLabel.attributedText = attributeString;
    
}
- (NSAttributedString *)setupCountLabelText:(NSString *)allText attributeText:(NSString *)attributeText {
    NSRange range = [allText rangeOfString:attributeText];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:allText];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, allText.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor systemBlueColor] range:range];
    return attributeString;
}

// MARK: 私有方法
- (void)p_addPasteActionofView:(UILabel *)label {
    label.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [label addGestureRecognizer:touch];
}
- (void)handleTap:(UILongPressGestureRecognizer *)ges {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *subString = [self.titleLabel.text substringWithRange:NSMakeRange(3, self.titleLabel.text.length-3)];
    
    [pasteboard setString:subString];
    [self.view makeToast:@"复制成功" duration:2 position:CSToastPositionCenter];
}
// MARK: UIResponder Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.playTextView resignFirstResponder];
    [self updataTextCountWithTextLength:self.playTextView.text.length];
}


@end
