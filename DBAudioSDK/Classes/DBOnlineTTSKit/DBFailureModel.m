//
//  DBFailureModel.m
//  WebSocketDemo
//
//  Created by linxi on 2019/11/13.
//  Copyright © 2019 newbike. All rights reserved.
//

#import "DBFailureModel.h"

/// 错误码4xxxx表示客户端参数错误，5xxxx表示服务端内部错误
@implementation DBFailureModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"code %zd ,message:%@,trace_id:%@",self.code,self.message,self.trace_id];
}


@end
