//
//  DBVPResponseModel.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBVPResponseModel.h"

@implementation DBVPResponseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"key:%@",key);
}

+ (instancetype)responseModelWithError:(NSError *)error {
    DBVPResponseModel *model = [[DBVPResponseModel alloc]init];
    model.err_msg = error.description;
    model.err_no = @(error.code);
    return model;
}

@end

@implementation DBRegisterVPResponseModel



@end

@implementation DBMatchOneVPResponseModel


@end

@implementation DBMatchMoreVPResponseModel


@end

@implementation DBVPStatusResponnseModel



@end
