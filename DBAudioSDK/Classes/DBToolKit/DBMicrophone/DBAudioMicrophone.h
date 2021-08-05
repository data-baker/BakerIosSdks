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

@class DBAudioMicrophone;
@protocol DBAudioMicrophoneDelegate <NSObject>
@optional
- (void)audioMicrophone:(DBAudioMicrophone *)microphone hasAudioPCMByte:(Byte *)pcmByte audioByteSize:(UInt32)byteSize;

- (void)audioCallBackVoiceGrade:(NSInteger)grade;

- (void)microphoneonError:(NSInteger)code message:(NSString *)message;

@end

/// 录音器，通过thread的方式驱动数据
@interface DBAudioMicrophone : NSObject
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) AudioStreamBasicDescription audioDescription; //音频输出参数
@property (nonatomic, copy) void(^configAudioSession)(AVAudioSession *audioSession);
@property (nonatomic, weak) id <DBAudioMicrophoneDelegate> delegate;

- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel configAudioSession:(void (^)(AVAudioSession *audioSesson))sessionConfig;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel;
- (instancetype)initWithSampleRate:(NSInteger)sampleRate;

- (void)startRecord;
- (void)stop;
- (void)pause;
@end
