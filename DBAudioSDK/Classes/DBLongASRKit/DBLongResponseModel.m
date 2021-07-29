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
    NSLog(@"key:%@ value:%@",key,value);
}
@end
