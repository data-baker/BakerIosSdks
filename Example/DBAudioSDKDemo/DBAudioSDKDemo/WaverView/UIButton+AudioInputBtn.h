//
//  UIButton+AudioInputBtn.h
//  Waver
//
//  Created by ghx on 2020/7/29.
//  Copyright © 2020 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXAudioInputView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^LongPressTimeBlk)(NSTimeInterval time,BOOL isLong);

@interface UIButton (AudioInputBtn)<UIGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) NSTimer * timer;
@property (nonatomic, assign, readonly) CGFloat longPressTime;

@property (nonatomic, strong ,readonly) UILongPressGestureRecognizer * longPressGes;
@property (nonatomic, copy ,readonly) LongPressTimeBlk longPressTimeBlk; //判断按钮长按短按


/// 添加手势
/// @param blk  手势回调 长按，短按
- (void)addGesWithBlk:(LongPressTimeBlk)blk;


/// 手势关联给 音频输入的按钮 【联动】  >>>>>调用顺序在  addGesWithBlk 之后 <<<<<<
/// @param audioInput  音频输入按钮
- (void)addGesCombineToInput:(HXAudioInputView *)audioInput;
@end

NS_ASSUME_NONNULL_END
