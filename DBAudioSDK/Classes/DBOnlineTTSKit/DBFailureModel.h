//
//  DBFailureModel.h
//  WebSocketDemo
//
//  Created by linxi on 2019/11/13.
//  Copyright © 2019 newbike. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBFailureModel : NSObject
@property(nonatomic,assign)NSInteger code;

@property(nonatomic,copy)NSString * message;

@property(nonatomic,copy)NSString * trace_id;

@end

NS_ASSUME_NONNULL_END
