//
//  DBSynthesizerRequestParam.m
//  WebSocketDemo
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 newbike. All rights reserved.
//

#import "DBSynthesizerRequestParam.h"

@implementation DBSynthesizerRequestParam


-(NSString *)description {
    return [NSString stringWithFormat:@"voice = %@\ntext = %@\nlanguage = %@\nspeed = %@\nvolume = %@\npitch = %@\nrate = %zd\naudioType = %zd",self.voice,self.text,self.language,self.speed,self.volume,self.pitch,self.rate,self.audioType];
}

@end
