//


#import "NSTimer+BlocksSupport.h"

@implementation NSTimer (BlocksSupport)

+ (NSTimer*)bs_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(void))block repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(bs_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)bs_blockInvoke:(NSTimer*)timer
{
    void (^block)(void) = timer.userInfo;
    if (block)
    {
        block();
    }
}
@end
