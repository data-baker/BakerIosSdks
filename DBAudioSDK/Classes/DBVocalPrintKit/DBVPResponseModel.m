//
//  DBVPResponseModel.m
//  DBAudioSDKDemo
//
//  Created by linxi on 2021/11/8.
//

#import "DBVPResponseModel.h"
#import "DBLogCollectKit.h"

@implementation DBVPResponseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    LogerInfo(@"key:%@",key);
}

+ (instancetype)responseModelWithError:(NSError *)error {
    DBVPResponseModel *model = [[DBVPResponseModel alloc]init];
    model.err_msg = error.description;
    model.err_no = @(error.code);
    return model;
}

@end

@implementation DBRegisterVPResponseModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    LogerInfo(@"key:%@",key);
}



@end

@implementation DBMatchOneVPResponseModel


@end

@implementation DBMatchMoreVPResponseModel

- (void)setValue:(id)value forKey:(NSString *)key {
    [super setValue:value forKey:key]; // 必须调用父类方法
    if ([key isEqualToString:@"matchList"]) {
        
        NSMutableArray * subArr = [NSMutableArray array];

        for (NSDictionary *dict in value) {
            DBMatchListModel *model = [[DBMatchListModel alloc]init];
            [model setValuesForKeysWithDictionary:dict];
            [subArr addObject:model];
        }
        self.matchList = subArr;
    }
}

@end

@implementation DBMatchListModel




@end

@implementation DBVPStatusResponnseModel


@end
