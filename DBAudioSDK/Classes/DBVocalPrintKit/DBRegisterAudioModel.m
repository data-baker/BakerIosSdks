//
//  DBAudioDataModel.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBRegisterAudioModel.h"

@interface DBRegisterAudioModel ()
@property(nonatomic,copy)NSString * format;
@end

@implementation DBRegisterAudioModel

+ (instancetype)registerAudioModelWithToken:(NSString *)accessToken audioData:(NSData *)data registerId:(NSString *)registerId name:(NSString *)name scoreThreshold:(NSNumber *)scoreThreshold {
    DBRegisterAudioModel *model = [[DBRegisterAudioModel alloc]init];
    model.accessToken = accessToken;
    model.audioData = data;
    model.registerId = registerId;
    model.name = name;
    model.scoreThreshold = scoreThreshold;
    model.format = @"pcm";
    return model;
}

@end
