//


#import <Foundation/Foundation.h>

@interface NSTimer (BlocksSupport)
+ (NSTimer*)bs_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(void))block repeats:(BOOL)repeats;
@end
