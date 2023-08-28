//
//  DBTextModel.m
//  DBAudioSDK
//
//  Created by 林喜 on 2023/8/24.
//

#import "DBTextModel.h"

@implementation DBTextModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}

- (void)setNilValueForKey:(NSString *)key {
    
}

//- (instancetype)initWithText:(NSString *)text {
//    if (self = [super init]) {
//        self.text = text;
//    }
//    return self;
//}

+ (instancetype)textModelWithText:(NSString *)text {
    DBTextModel *model = [[DBTextModel alloc]init];
    model.text = text;
    return model;
}

- (NSString *)description {
    NSString *info = [NSString stringWithFormat:@" filePath:%@, index :%@ ,text:%@",self.filePath,@(self.index),self.recordText];
    return info;
}

@end
