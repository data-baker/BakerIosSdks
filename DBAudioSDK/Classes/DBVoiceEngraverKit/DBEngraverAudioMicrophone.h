//
//  STAudioMicrophone.h
//  PCMPlayerDemo
//
//  Created by linxi on 2017/8/24.
//  Copyright © 2017年 linxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class DBEngraverAudioMicrophone;
@protocol DBAudioMicrophoneDelegate <NSObject>
@optional
// 麦克风的回调音频数据回调
- (void)audioMicrophone:(DBEngraverAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize;
// 声音分贝大小的监测回调
- (void)audioCallBackVoiceGrade:(NSInteger)grade;
// 音频被打断事件的回调
- (void)audioMicrophonInterrupted;

@end

// 录音器，audioQueue的方式驱动
@interface DBEngraverAudioMicrophone : NSObject
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) AudioStreamBasicDescription audioDescription; //音频输出参数
@property (nonatomic, copy) void(^configAudioSession)(AVAudioSession *audioSession);
@property (nonatomic, weak) id <DBAudioMicrophoneDelegate> delegate;

- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel configAudioSession:(void (^)(AVAudioSession *audioSesson))sessionConfig;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate;

- (void)start;
- (void)stop;
- (void)pause;
@end
