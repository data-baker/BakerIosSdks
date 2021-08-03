//
//  DBOnlineModel.m
//  DBTTSScocketSDK
//
//  Created by linxi on 2019/11/21.
//  Copyright © 2019 newbike. All rights reserved.
//

#import "DBOnlineResponseModel.h"

@implementation DBOnlineResponseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (NSInteger)index {
    return [self.idx intValue];
}

- (BOOL)endFlag {
    return [self.end_flag boolValue];
}
- (NSData *)convertAudioData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self.audio_data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

- (NSString *)base64DencodeString:(NSString *)base64String
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"idx :%@，\n audio_type:%@，\n end_flag:%@，\n interval:%@, \n audio_datalenth:%lu",self.idx,self.audio_type,self.end_flag,self.interval,(long)self.audio_data.length];
}
@end
