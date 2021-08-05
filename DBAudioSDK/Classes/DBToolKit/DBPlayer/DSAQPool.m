//
//  DSAQPool.m
//  DiSpecialDriver
//
//  Created by linxi on 2019/12/25.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import "DSAQPool.h"

@interface AudioQueueBufferRefWrapper ()
@property (nonatomic,strong) AQPoolCallBack callBack;
@end

@implementation AudioQueueBufferRefWrapper{
    AudioQueueBufferRef _ref;
    UInt32 _size;
}
-(AudioQueueBufferRef)ref{
    return _ref;
}
-(UInt32)size{
    return _size;
}
- (instancetype)initWithSize:(UInt32)size queue:(AudioQueueRef)queue
{
    self = [super init];
    if (self) {
        _size = size;
        if(AudioQueueAllocateBuffer(queue,size,&_ref) != noErr){
            return nil;
        }///创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
    }
    return self;
}
@end

@interface DSAQPool ()
-(void)playCallBack:(AudioQueueBufferRef)buf;
@end

static void AudioPlayerAQInputCallbackV2(void* inUserData,AudioQueueRef outQ, AudioQueueBufferRef outQB){
    
    DSAQPool* pool = (__bridge DSAQPool*)inUserData;
    [pool playCallBack:outQB];
}


static DSAQPool *_instance = nil;

@implementation DSAQPool{
    AudioStreamBasicDescription audioDescription;///音频参数
    AudioQueueRef audioQueue;//音频播放队列
    NSMutableArray *_buffers;
    BOOL _started;
}
+(instancetype)pool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DSAQPool alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _buffers = [NSMutableArray array];
        
        _started = NO;
        
        audioQueue = NULL;
        ///设置音频参数
        audioDescription.mSampleRate =16000;//采样率
        
        audioDescription.mFormatID =kAudioFormatLinearPCM;
        
        audioDescription.mFormatFlags =kLinearPCMFormatFlagIsSignedInteger |kAudioFormatFlagIsPacked;
        
        audioDescription.mChannelsPerFrame =1;///单声道
        
        audioDescription.mFramesPerPacket =1;//每一个packet一侦数据
        
        audioDescription.mBitsPerChannel =16;//每个采样点16bit量化
        
        audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel / 8) * audioDescription.mChannelsPerFrame;
        
        //    audioDescription.mBytesPerPacket =audioDescription.mBytesPerFrame;
        audioDescription.mBytesPerPacket = audioDescription.mFramesPerPacket*audioDescription.mBytesPerFrame;
        
        AudioQueueNewOutput(&audioDescription,AudioPlayerAQInputCallbackV2, (__bridge void*)self,CFRunLoopGetMain(),kCFRunLoopCommonModes,0, &audioQueue);//使用player的内部线程播放
    }
    
    return self;
}

-(AudioQueueBufferRefWrapper*)dequeueBuffer:(UInt32)dataSize{
    NSArray *temp = nil;
    @synchronized (_buffers) {
        temp = [NSArray arrayWithArray:_buffers];
    }
    for (AudioQueueBufferRefWrapper *wrapper in temp) {
        if (wrapper.inUse == NO && wrapper.size > dataSize) {
            return wrapper;
        }
    }
    
    //alloc new
    AudioQueueBufferRefWrapper *wp = [[AudioQueueBufferRefWrapper alloc] initWithSize:dataSize*2 queue:audioQueue];
    return wp;
}

-(AudioQueueBufferRefWrapper*)enqueueData:(NSData *)audioPCMData playCallBack:(AQPoolCallBack)callBack{
    
    if (!_started) {
        AudioQueueStart(audioQueue, NULL);
    }
    
    AudioQueueBufferRefWrapper *aqwrapper = [self dequeueBuffer:(UInt32)audioPCMData.length];
    if (aqwrapper) {
        AudioQueueBufferRef audioQueueBuffer = aqwrapper.ref;
        
        NSData *pcmData = audioPCMData;
        const void *pcmByte = pcmData.bytes;
        audioQueueBuffer->mAudioDataByteSize = (UInt32)pcmData.length;
        Byte* audiodata = (Byte*)audioQueueBuffer->mAudioData;
        for (int i =0; i < pcmData.length; i++) {
            audiodata[i] = ((Byte*)pcmByte)[i];
        }
        
        if([self enqueueBuffer:aqwrapper]){
            aqwrapper.callBack = callBack;
            return aqwrapper;
        }else{
            return NULL;
        }
        
    }else{
        //DDLogError(@"dequeueBuffer fail %@",@(audioPCMData.length));
        return NULL;
    }
}

-(BOOL)enqueueBuffer:(AudioQueueBufferRefWrapper*)buf{
    
    if(AudioQueueEnqueueBuffer(audioQueue, buf.ref,0,NULL) == noErr){
        buf.inUse = YES;
        @synchronized (_buffers) {
            [_buffers addObject:buf];
        }
        return YES;
    }else{
        //DDLogError(@"AudioQueueEnqueueBuffer error.");
        return NO;
    }
    
}

-(void)playCallBack:(AudioQueueBufferRef)buf{
    NSArray *temp = nil;
    @synchronized (_buffers) {
        temp = [NSArray arrayWithArray:_buffers];
    }
    for (AudioQueueBufferRefWrapper *wrapper in temp) {
        if (wrapper.ref == buf) {
            
            wrapper.inUse = NO;
            if(wrapper.callBack) {wrapper.callBack(wrapper); wrapper.callBack = nil;}
            
            break;
        }
    }
    
    //下面的代码组合起来在播完时停掉queue
    for (AudioQueueBufferRefWrapper *wrapper in temp) {
        if (wrapper.inUse) {
            return;
        }
    }
    AudioQueueStop(audioQueue, true);
    _started = NO;

}

-(void)stopBuffers:(NSArray<AudioQueueBufferRefWrapper *> *)bufs{
    if (bufs.count>0) {
        AudioQueueStop(audioQueue, true);
        _started = NO;
    }
}

@end
