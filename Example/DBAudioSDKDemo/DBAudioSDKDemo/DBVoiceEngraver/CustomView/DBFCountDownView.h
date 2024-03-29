//
//  DBFCountDownView.h
//  Biaobei
//
//  Created by biaobei on 2022/6/21.
//  Copyright © 2022 标贝科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

#define kiPhone6BasedScale ([UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width / 375.f)

#define kFitSize(x)  (ceilf((kiPhone6BasedScale * (x)) * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale)

NS_ASSUME_NONNULL_BEGIN

@interface DBFCountDownView : UIView

// yes: 表示当前的前后静音段时间，这个时候会提示用户保持安静
- (BOOL)isCountDown;

- (void)showViewWithIsStart:(BOOL)isStart completeHandler:(dispatch_block_t)handler;


@end

NS_ASSUME_NONNULL_END
