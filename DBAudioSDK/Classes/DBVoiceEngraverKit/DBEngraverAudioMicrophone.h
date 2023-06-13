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
- (void)audioMicrophone:(DBEngraverAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize;

- (void)audioCallBackVoiceGrade:(NSInteger)grade;

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
