//
//  DBPermanentThread.m
//  DBPermanentThread
//
//  Created by biaobei on 2022/5/11.
//

#import "DBPermanentThread.h"

@interface DBThread : NSThread

@end

@implementation DBThread
- (void)dealloc {
    NSLog(@"%s",__func__);
}
@end


typedef void (^permanentThreadTask)(void);
@interface DBPermanentThread ()
@property(nonatomic,strong)DBThread * innerThread;
@property(nonatomic,assign,getter=isStopped)BOOL stopped;

@end
@implementation DBPermanentThread

- (instancetype)init {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 10.0, *)) {
            self.innerThread = [[DBThread alloc] initWithBlock:^{
                [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc]init] forMode:NSRunLoopCommonModes];
                while (weakSelf && !weakSelf.isStopped) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
            }];
        } else {
            NSLog(@"iOS 10 以下，不支持");
            // Fallback on earlier versions
        }
        [self.innerThread start];
    }
    return self;
}

- (void)run {
    if (self.innerThread == nil) {
        return;
    }
    [self.innerThread start];
}

- (void)executeTask:(DBPermanentThreadTask)task {
    if (self.innerThread == nil || task == nil) {
        return;
    }
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
    
}
- (void) __executeTask:(permanentThreadTask)task {
    task();
}
- (void)stop {
    if (self.innerThread == nil) return;
    [self performSelector:@selector(__stopThread) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void) __stopThread {
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)dealloc {
    if (self.innerThread != nil){
        [self stop];
    }
    NSLog(@"%s", __func__);
}


@end
