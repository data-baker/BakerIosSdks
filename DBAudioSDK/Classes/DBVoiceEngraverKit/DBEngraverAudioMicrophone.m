//
//  STAudioMicrophone.m
//  PCMPlayerDemo
//
//  Created by linxi on 2017/8/24.
//  Copyright © 2017年 linxi. All rights reserved.
//

#import "DBEngraverAudioMicrophone.h"

#define kAudioQueueBufferCount (4)

static UInt32 kAudioBufferSize = 1024*2*2;

void EngraverAudioAQInputCallback(void * __nullable               inUserData,
                          AudioQueueRef                   inAQ,
                          AudioQueueBufferRef             inBuffer,
                          const AudioTimeStamp *          inStartTime,
                          UInt32                          inNumberPacketDescriptions,
                          const AudioStreamPacketDescription * __nullable inPacketDescs);

@interface DBEngraverAudioMicrophone () {
    AudioQueueBufferRef _audioQueueBuffers[kAudioQueueBufferCount];
    BOOL _isOn;
}



@property (nonatomic, strong) NSLock *synlock; // 同步锁
@property (nonatomic, assign) AudioQueueRef audioQueue;//音频播放队列

@property (nonatomic, assign) BOOL isAudioSetup;

@property (nonatomic, assign) NSInteger numOfChannel;

@property (nonatomic, assign) BOOL bufferIsAlloc;
@end

@implementation DBEngraverAudioMicrophone

+ (AudioStreamBasicDescription)defaultAudioDescriptionWithSampleRate:(Float64)sampleRate numOfChannel:(NSInteger)numOfChannel {
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mChannelsPerFrame = (UInt32)numOfChannel;
    asbd.mFramesPerPacket = 1;//每一个packet一侦数据
    asbd.mBitsPerChannel = 16;//每个采样点16bit量化
    asbd.mBytesPerFrame = (asbd.mBitsPerChannel/8) * asbd.mChannelsPerFrame;
    asbd.mBytesPerPacket = asbd.mBytesPerFrame * asbd.mFramesPerPacket;
    
    return asbd;
}

- (void)dealloc {
    [self stop];
    [self freeAudioBuffers];
    NSLog(@"%@ Dealloc", self);
}

- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel configAudioSession:(void (^)(AVAudioSession *audioSesson))sessionConfig {
    self = [super init];
    if (self) {
        _synlock = [[NSLock alloc] init];
        _sampleRate = sampleRate;
        _numOfChannel = numOfChannel;
        _audioDescription = [DBEngraverAudioMicrophone defaultAudioDescriptionWithSampleRate:sampleRate numOfChannel:numOfChannel];
        self.configAudioSession = sessionConfig;
        [self setupAudioInput];
    }
    return self;
}


- (instancetype)initWithSampleRate:(NSInteger)sampleRate numerOfChannel:(NSInteger)numOfChannel {
    return [self initWithSampleRate:sampleRate numerOfChannel:numOfChannel configAudioSession:nil];
}


- (instancetype)initWithSampleRate:(NSInteger)sampleRate {
    return [self initWithSampleRate:sampleRate numerOfChannel:2];
}

- (instancetype)init {
    return [self initWithSampleRate:44100];
}

- (void)start {
    if (self.isAudioSetup) {
        AudioQueueStart(_audioQueue, NULL);
        _isOn = YES;
    }
}

- (void)stop {
    if (self.isAudioSetup) {
        AudioQueueStop(_audioQueue, true);
        _isOn = NO;
    }
}

- (void)pause {
    if (self.isAudioSetup) {
        AudioQueuePause(_audioQueue);
        _isOn = NO;
    }
}

#pragma mark --- Audio Play Contorl
- (void)setupAudioInput {
    if (!self.isAudioSetup) {
        [self audioNewInput];
        [self allocAudioBuffers];
        if (self.configAudioSession) {
            self.configAudioSession([AVAudioSession sharedInstance]);
        } else {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
            [[AVAudioSession sharedInstance] setPreferredSampleRate:self.sampleRate error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error) {
                NSLog(@"AVAudioSession Error: %@", error.localizedDescription);
            }
        }
        self.isAudioSetup = YES;
    }
}

// TODO: Create Audio Output
- (void)audioNewInput {
    /// 创建一个新的从audioqueue到硬件层的通道
    //  AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &audioQueue);///使用当前线程播
    AudioQueueNewInput(&_audioDescription, EngraverAudioAQInputCallback, (__bridge void * _Nullable)(self), NULL, kCFRunLoopCommonModes, 0, &_audioQueue);
    
}



#pragma mark --- Setup Audio Buffer
// TODO: Alloc Audio Buffer
- (void)allocAudioBuffers {
    // 添加buffer区
    for(int i=0; i<kAudioQueueBufferCount; i++) {
        int result =  AudioQueueAllocateBuffer(_audioQueue, kAudioBufferSize, &_audioQueueBuffers[i]);
//        NSLog(@"Mic AudioQueueAllocateBuffer i = %d,result = %d", i, result);
        AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffers[i], 0, NULL);
    }
    self.bufferIsAlloc = YES;
}

// TODO: Free Audio Buffer
- (void)freeAudioBuffers {
    if (!self.bufferIsAlloc) {
        return;
    }
    
    for(int i=0; i<kAudioQueueBufferCount; i++) {
        int result = AudioQueueFreeBuffer(_audioQueue, _audioQueueBuffers[i]);
        
        NSLog(@"AudioQueueFreeBuffer i = %d,result = %d", i, result);
    }
    AudioQueueDispose(_audioQueue, YES);
    self.bufferIsAlloc = NO;
}


- (void)processAudioBuffer:(AudioQueueBufferRef)inBuffer withQueue:(AudioQueueRef)inAudioQueue {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioMicrophone:hasAudioPCMByte:audioByteSize:)]) {
        
        NSData *data = [NSData dataWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        [self.delegate audioMicrophone:self hasAudioPCMByte:(Byte *)data.bytes audioByteSize:(UInt32)data.length];
        [self getVoiceVolume:data];
    }
    
    if (_isOn) {
        AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
    }
    
}

// 获取当前音量级别，取值需要考虑全平台
#pragma mark - 调用方法获取音量

-(void)getVoiceVolume:(NSData *)pcmData {
    if(pcmData ==nil) {
        return ;
    }
    long pcmAllLenght =0;
    short butterByte[pcmData.length/2];
    memcpy(butterByte, pcmData.bytes, pcmData.length);//frame_size * sizeof(short)
    // 将 buffer 内容取出，进行平方和运算
    for(int i =0; i < pcmData.length/2; i++){
        pcmAllLenght += butterByte[i] * butterByte[i];
    }
    double mean = pcmAllLenght / (double)pcmData.length;
    double volume =10*log10(mean);//volume为分贝数大小
//    NSLog(@"volume :%@",@(volume));
   
    if([self.delegate respondsToSelector:@selector(audioCallBackVoiceGrade:)]) {
        [self.delegate audioCallBackVoiceGrade:volume];
    }
}

    

@end

void EngraverAudioAQInputCallback(void * __nullable               inUserData,
                          AudioQueueRef                   inAQ,
                          AudioQueueBufferRef             inBuffer,
                          const AudioTimeStamp *          inStartTime,
                          UInt32                          inNumberPacket,
                          const AudioStreamPacketDescription * __nullable inPacketDescs) {
    
    DBEngraverAudioMicrophone * SELF = (__bridge DBEngraverAudioMicrophone *)inUserData;
//    NSLog(@"Mic Audio Callback");
    if (inNumberPacket > 0)
    {
        [SELF processAudioBuffer:inBuffer withQueue:inAQ];
    }
}
