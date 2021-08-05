//
//  DSAQPool.h
//  DiSpecialDriver
//
//  Created by linxi on 2019/12/25.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioQueueBufferRefWrapper : NSObject
@property (nonatomic) BOOL inUse;
-(instancetype)initWithSize:(UInt32)size queue:(AudioQueueRef)queue;
-(AudioQueueBufferRef)ref;
-(UInt32)size;
@end

typedef void (^AQPoolCallBack)(AudioQueueBufferRefWrapper *params);

@protocol DSAQPoolDelegate <NSObject>
-(void)playCallBack:(AudioQueueBufferRefWrapper*)buf;
@end

@interface DSAQPool : NSObject

+(instancetype)pool;

-(AudioQueueBufferRefWrapper*)enqueueData:(NSData*)data playCallBack:(AQPoolCallBack)callBack;
-(void)stopBuffers:(NSArray<AudioQueueBufferRefWrapper*>*)bufs;

@end
