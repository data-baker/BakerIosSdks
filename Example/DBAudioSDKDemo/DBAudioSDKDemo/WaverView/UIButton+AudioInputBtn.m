//
//  UIButton+AudioInputBtn.m
//  Waver
//
//  Created by ghx on 2020/7/29.
//  Copyright © 2020 Catch Inc. All rights reserved.
//

#import "UIButton+AudioInputBtn.h"
#import <objc/runtime.h>

static CGFloat AUDIO_INPUT_MIN_LONG_SEC = 0.3; //多长时间识别为长按


@implementation UIButton (AudioInputBtn)

@dynamic timer;
@dynamic longPressTimeBlk;
@dynamic longPressGes;
@dynamic longPressTime;

#pragma mark- Public Method
- (void)resetAndStartTimer {
    self.longPressTime = 0;
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(incrementCounter) userInfo:nil repeats:YES];
}

- (void)endPress {
    if ([self.timer isValid]) {
        if (self.longPressTime >= AUDIO_INPUT_MIN_LONG_SEC) {
            [self.timer invalidate];
            if (self.longPressTimeBlk) {
                self.longPressTimeBlk(self.longPressTime,YES);
                self.longPressTime = 0;
            }
        } else {
            [self.timer invalidate];
            if (self.longPressTimeBlk) {
                self.longPressTimeBlk(self.longPressTime,NO);
                self.longPressTime = 0;
            }
        }
    }
}

- (void)addGesWithBlk:(LongPressTimeBlk)blk {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gesPressAction:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.0;
    [self addGestureRecognizer:longPress];
    
    self.longPressGes = longPress;
    
    [self setLongPressTimeBlk:^(NSTimeInterval time, BOOL isLong) {
        if (isLong) {
            //长按触发
//            NSLog(@">>>长按触发>>>");
           
        } else {
            //点击触发
//            NSLog(@">>>点击触发>>>");
        }
         blk(time,isLong);
    }];
}

- (void)addGesCombineToInput:(HXAudioInputView *)audioInput {
    if (self.longPressGes) {
        [self.longPressGes addTarget:audioInput action:@selector(longPressGesAction:)];
    }
         
}


#pragma mark- Setting Getting
- (void)setTimer:(NSTimer *)timer {
    objc_setAssociatedObject(self, @selector(timer), timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSTimer *)timer {
    return  objc_getAssociatedObject(self, @selector(timer));
}

- (void)setLongPressTime:(CGFloat)longPressTime {
    objc_setAssociatedObject(self, @selector(longPressTime), @(longPressTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)longPressTime {
    return  [objc_getAssociatedObject(self, @selector(longPressTime)) floatValue];
}

- (void)setLongPressGes:(UILongPressGestureRecognizer *)longPressGes {
    objc_setAssociatedObject(self, @selector(longPressGes), longPressGes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UILongPressGestureRecognizer *)longPressGes {
    return  objc_getAssociatedObject(self, @selector(longPressGes));
}

- (void)setLongPressTimeBlk:(LongPressTimeBlk)longPressTimeBlk {
    objc_setAssociatedObject(self, @selector(longPressTimeBlk), longPressTimeBlk, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (LongPressTimeBlk)longPressTimeBlk {
    return  objc_getAssociatedObject(self, @selector(longPressTimeBlk));
}

#pragma mark- 长按时间计算
- (void)incrementCounter {
    self.longPressTime += 0.01;
    
    if (self.longPressTime >= AUDIO_INPUT_MIN_LONG_SEC) {
        [self.timer invalidate];
        
        if (self.longPressTimeBlk) {
            self.longPressTimeBlk(self.longPressTime,YES);
            self.longPressTime = 0;
            //            self.longPressTimeBlk = nil;
        }
    }
}

#pragma mark- Ges
- (void)gesPressAction:(UIGestureRecognizer *)sender {
    
    
    __weak typeof(self) weakSelf = self;
    UIButton * button = (UIButton *)[sender view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        button.selected = YES;
        [button resetAndStartTimer];

    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
        [button endPress];
    }
    
    
    
}


@end
