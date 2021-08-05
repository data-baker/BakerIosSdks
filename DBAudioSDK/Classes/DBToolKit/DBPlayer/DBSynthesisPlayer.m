//
//  DBSynthesisPlayerManager.m
//  DBFlowTTS
//
//  Created by linxi on 2019/12/20.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import "DBSynthesisPlayer.h"


@implementation DBSynthesisPlayer

- (void)startPlay {
    [self.pcmDataPlayer startPlay];
}

- (void)pausePlay {
    [self.pcmDataPlayer pausePlay];
    
}
- (void)stopPlay {
    [self.pcmDataPlayer stopPlay];
    self.pcmDataPlayer = nil;
}

// 使用懒加载的方式
- (DBPCMDataPlayer *)pcmDataPlayer {
    if (!_pcmDataPlayer) {
        if (self.audioType == DBTTSAudioTypePCM8K) {
            _pcmDataPlayer = [[DBPCMDataPlayer alloc]initWithType:@"DBTTSAudioTypePCM8K"];
        }else {
            _pcmDataPlayer = [[DBPCMDataPlayer alloc]initWithType:@"DBTTSAudioTypePCM16K"];
        }
        
        _pcmDataPlayer.delegate = self;
    }
    return _pcmDataPlayer;
}


- (void)appendData:(NSData *)data totalDatalength:(float)length endFlag:(BOOL)endflag {
    [self.pcmDataPlayer appendData:data totalDatalength:length endFlag:endflag];
}

- (BOOL)isFinished {
    return self.pcmDataPlayer.isFinished;
}
- (void)setFinished:(BOOL)finished {
    
    self.pcmDataPlayer.finished = finished;
}

- (BOOL)isReadyToPlay {
    return self.pcmDataPlayer.isReadyToPlay;
}
- (BOOL)isPlayerPlaying {
    return self.pcmDataPlayer.isPlayerPlaying;
}
- (NSInteger)currentPlayPosition {
    return self.pcmDataPlayer.currentPlayPosition;
}

- (NSInteger)audioLength {
    return self.pcmDataPlayer.audioLength;
}

// MAKR: 播放器相关的回调

- (void)readlyToPlay {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(readlyToPlay)]) {
        [self.delegate readlyToPlay];
    }
}

- (void)playPausedIfNeed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playPausedIfNeed)]) {
        [self.delegate playPausedIfNeed];
    }
    
}

- (void)playResumeIfNeed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playResumeIfNeed)]) {
        [self.delegate playResumeIfNeed];
    }
}

- (void)playFinished {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playFinished)]) {
        [self.delegate playFinished];
    }
    
}

- (void)updateBufferPositon:(float)bufferPosition {
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateBufferPositon:)]) {
        [self.delegate updateBufferPositon:bufferPosition];
    }
}

- (void)playerCallBackFaiure:(NSString *)errorStr {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerFaiure:)]) {
        [self.delegate playerFaiure:errorStr];
    }
}



@end
