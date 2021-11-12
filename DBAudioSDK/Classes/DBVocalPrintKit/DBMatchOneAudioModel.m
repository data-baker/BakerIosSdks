//
//  DBMatchAudioModel.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBMatchOneAudioModel.h"

@interface DBMatchOneAudioModel ()

@property(nonatomic,copy)NSString * format;
@end

@implementation DBMatchOneAudioModel
+ (instancetype)mactchOneAudioModelWithToken:(NSString *)accessToken audioData:(NSData *)data matchId:(NSString *)matchId scoreThreshold:(NSNumber *)scoreThreshold {
    DBMatchOneAudioModel *model = [[DBMatchOneAudioModel alloc]init];
    model.accseeToken = accessToken;
    model.audioData = data;
    model.format= @"pcm";
    model.matchId = matchId;
    model.scoreThreshold = scoreThreshold;
    return model;
}

@end
