//
//  DBPermanentThread.h
//  DBPermanentThread
//
//  Created by biaobei on 2022/5/11.
//

#import <Foundation/Foundation.h>
typedef void(^DBPermanentThreadTask) (void);

NS_ASSUME_NONNULL_BEGIN

@interface DBPermanentThread : NSObject

- (void)executeTask:(DBPermanentThreadTask)task;


@end

NS_ASSUME_NONNULL_END
