//
//  DBMatchMoreAudioModel.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBMatchMoreAudioModel.h"

@implementation DBMatchMoreAudioModel

+ (instancetype)mactchMoreAudioModelWithToken:(NSString *)accessToken audioData:(NSData *)data listNum:(NSNumber *)listNum scoreThreshold:(NSNumber *)scoreThreshold {
    DBMatchMoreAudioModel *model = [[DBMatchMoreAudioModel alloc]init];
    model.accseeToken = accessToken;
    model.audioData = data;
    model.listNum = listNum;
    model.scoreThreshold = scoreThreshold;
    model.format = @"pcm";
    return model;
}

@end
