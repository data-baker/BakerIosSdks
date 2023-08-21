//
//  DBVoiceDetectionUtil.m
//  DBVoiceEngraver
//
//  Created by linxi on 2020/3/4.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceDetectionUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "DBVoiceEngraverEnumerte.h"

@interface DBVoiceDetectionUtil ()
{
    AVAudioRecorder * recorder;
    NSTimer * levelTimer;
}
@property (nonatomic,assign)NSInteger runloopNumber;
@property (nonatomic,assign)float average;
@property(nonatomic)  dispatch_semaphore_t waitMicrophonePermission;
@end

@implementation DBVoiceDetectionUtil
//检查麦克风权限
- (BOOL)checkAudioStatus {
    self.average = 0;
    self.runloopNumber = 0;
    self.waitMicrophonePermission = dispatch_semaphore_create(0);
    __block BOOL hasMicrophonePermission = true;
     if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
         [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
             hasMicrophonePermission = granted;
            dispatch_semaphore_signal(self.waitMicrophonePermission);
         }];
         
         dispatch_semaphore_wait(self.waitMicrophonePermission, DISPATCH_TIME_FOREVER);
     }
    return hasMicrophonePermission;
}



-(DBErrorState)startDBDetection {
   BOOL hasMicrophonePermission =  [self checkAudioStatus];
    if (!hasMicrophonePermission) {
        return DBErrorStateMircrophoneNotPermission ;
    }
    
    /* 必须添加这句话，否则在模拟器可以，在真机上获取始终是0  */
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    /* 不需要保存录音文件 */
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder)
    {
        [self addInterruptAbserver];
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder recordForDuration:3];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else
    {
        NSLog(@"%@", [error description]);
    }
    return DBErrorStateNOError;
}

/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    float power = [recorder averagePowerForChannel:0];// 均值
    power = power + 160  - 50;
    int dB = 0;
    if (power < 0.f) {
        dB = 0;
    } else if (power < 40.f) {
        dB = (int)(power * 0.875);
    } else if (power < 100.f) {
        dB = (int)(power - 15);
    } else if (power < 110.f) {
        dB = (int)(power * 2.5 - 165);
    } else {
        dB = 110;
    }
    
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    dispatch_async(dispatch_get_main_queue(), ^{
        self.runloopNumber++;
        self.average += dB;
        if (self.runloopNumber == 10) {
            [self  delegateCallDBResult:YES volume:dB];
            [self stopTest];
        }else  {
            [self delegateDbDetecting:dB];
        }
    });
}

- (void)delegateDbDetecting:(NSInteger)dB {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dbDetecting:)]) {
        [self.delegate dbDetecting:dB];
    }
}
- (void)delegateCallDBResult:(BOOL)ret volume:(NSInteger)volume {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dbDetectionResult:value:)]) {
        [self.delegate dbDetectionResult:ret value:volume];
    }
}

-(void)stopTest {
    //关闭定时器
    self.runloopNumber = 0;
    [levelTimer setFireDate:[NSDate distantFuture]];
    self.average = 0;
}


// 增加音频录制过程中被打断的拦截处理
- (void)addInterruptAbserver {
    // 监听音频打断事件
    // setup our audio session
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [self removeObserve];
    // add interruption handler
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionWasInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:sessionInstance];
    NSError *error = nil;
    [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(nil != error) NSLog(@"Error setting audio session category! %@", error);
    else {
        [sessionInstance setActive:YES error:&error];
        if (nil != error) NSLog(@"Error setting audio session active! %@", error);
    }
}
- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    NSLog(@"the notification is %@",notification);
    if (AVAudioSessionInterruptionTypeBegan == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        NSLog(@"begin");
        if (!recorder.isRecording) {
            return;
        };
        if(self.delegate && [self.delegate respondsToSelector:@selector(dbAudioInterrupted)]) {
            [recorder stop];
            [self stopTest];
            [self.delegate dbAudioInterrupted];
        }
        
    }
    else if (AVAudioSessionInterruptionTypeEnded == [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue])
    {
        NSLog(@"begin - end");
    }
}

- (void)removeObserve {
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:sessionInstance];
    NSError *error = nil;
    [sessionInstance setActive:YES error:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }
}

@end
