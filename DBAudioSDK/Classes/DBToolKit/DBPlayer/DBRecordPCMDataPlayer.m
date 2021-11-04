//
//  DSAudioQueuePlayer.m
//
//  Created by linxi on 2019/12/25.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import "DBRecordPCMDataPlayer.h"
#import "DSAQPool.h"

@interface DBRecordPCMDataPlayer ()<DSAQPoolDelegate>

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;

@property (nonatomic, assign)BOOL isStop;

@property (nonatomic, assign)BOOL isPlayDataEnd;

@property (nonatomic, strong) NSMutableArray *buffers;

@end

@implementation DBRecordPCMDataPlayer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.buffers = [NSMutableArray array];
        
        [self reset];
    }
    return self;
}

- (void)reset{
    
    self.isStop = NO;
    self.isPlayDataEnd = NO;

    _queue = dispatch_queue_create("com.PCMPlayer.MyQueue", DISPATCH_QUEUE_SERIAL);
    self.semaphore = dispatch_semaphore_create(1);
}

- (void)stop{
    self.isStop = YES;
    
    [[DSAQPool pool] stopBuffers:self.buffers];
    @synchronized (self.buffers) {
        [self.buffers removeAllObjects];
    }
    [self onFinishPlay];
}

- (void)play:(NSData *)audioPCMData
{
    dispatch_async(self.queue, ^{
        
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
        id bf = [[DSAQPool pool] enqueueData:audioPCMData playCallBack:^(AudioQueueBufferRefWrapper *params) {
            [self playCallBack:params];
        }];
        if (bf) {
            @synchronized (self.buffers) {
                [self.buffers addObject:bf];
            }
        }
        
        
        dispatch_semaphore_signal(self.semaphore);
        
    });
}

- (void)pause {
    [[DSAQPool pool] pause];
}


-(void)playCallBack:(AudioQueueBufferRefWrapper *)buf{
    @synchronized (self.buffers) {
        [self.buffers removeObject:buf];
    }
    
        BOOL finish = (self.buffers.count==0);
        
        if (finish || self.isStop) {
            [self onFinishPlay];
        }
    
}

-(void)onFinishPlay{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(PCMPlayerDidFinishPlaying)]) {
            [self.delegate PCMPlayerDidFinishPlaying];
            //避免代理无效
            self.delegate = nil;
        }
    });
}

-(void)playDataEnd{
    self.isPlayDataEnd = YES;
}
@end
