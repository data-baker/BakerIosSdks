//
//  DBResponseModel.m
//  DBASRFramework
//
//  Created by linxi on 2020/1/15.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "DBLongResponseModel.h"

@implementation DBLongResponseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%s,undefined key:%@value:%@",__func__,key,value);
    
    if ([key isEqualToString:@"words"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (NSDictionary *dic in value) {
                DBLWordsItem *wordItem = [[DBLWordsItem alloc]init];
                [wordItem setValuesForKeysWithDictionary:dic];
                [mutableArray addObject:wordItem];
            }
            self.bWords = mutableArray;
        }
    }
}
- (NSString *)description {
    NSString *wordText = @"";
    for (DBLWordsItem *item in self.bWords) {
        wordText = [wordText stringByAppendingFormat:@"confidence:%@,eos:%@,sos:%@,word:%@",item.confidence,item.eos,item.sos,item.word];
    }
    return [NSString stringWithFormat:@"text:%@-wordItem:%@",self.text,wordText];
    
}
@end


@implementation DBLWordsItem

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%s,undefined key:%@value:%@",__func__,key,value);
}

@end
