//
//  DBVoiceModel.m
//  DBVoiceEngraver
//
//  Created by linxi on 2020/3/10.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBVoiceModel.h"

@implementation DBVoiceModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    if ([key isEqualToString:@"id"]) {
////        self.myId = value;
//    }
}

@end

@implementation DBVoiceRecognizeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    if ([key isEqualToString:@"id"]) {
////        self.myId = value;
//    }
}

- (NSString *)description {
    NSString *info = [NSString stringWithFormat:@" filePath:%@, index :%@ ,text:%@",self.filePath,@(self.index),self.recordText];
    return info;
}

@end
