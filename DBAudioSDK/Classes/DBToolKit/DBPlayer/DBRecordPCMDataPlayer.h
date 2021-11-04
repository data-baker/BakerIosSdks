//
//  DSAudioQueuePlayer.h
//
//  Created by linxi on 2019/12/25.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define QUEUE_BUFFER_SIZE 10 //队列缓冲个数
#define MIN_SIZE_PER_FRAME 160000 //每侦最小数据长度

@protocol DBRecordPCMDataPlayerDelegate <NSObject>

- (void)PCMPlayerDidFinishPlaying;

@end

// 通过AQPool驱动的方式播放数据
@interface DBRecordPCMDataPlayer : NSObject

@property (nonatomic, weak)id<DBRecordPCMDataPlayerDelegate>delegate;

- (void)stop;

- (void)pause;

- (void)play:(NSData *)audioPCMData;

- (void)playDataEnd;

@end
