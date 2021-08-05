//
//  DBNetworkHelper.h
//  DBFlowTTS
//
//  Created by linxi on 2019/11/14.
//  Copyright © 2019 biaobei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DBCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^DBSuccessBlock)(NSDictionary *data);
typedef void (^DBFailureBlock)(NSError *error);

@interface DBNetworkHelper : NSObject
/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessBlock)successBlock failure:(DBFailureBlock)failureBlock;

/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(DBSuccessBlock)successBlock failure:(DBFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
