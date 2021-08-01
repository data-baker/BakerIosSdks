//
//  AudioInputView.h
//  Waver
//
//  Created by ghx on 2020/5/22.
//  Copyright © 2020 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,HXAudioInputViewShowType)
{
    HXAudioInputViewShowTypePressListhen, //长按监听，对应长按调用
    HXAudioInputViewShowTypeListen, //监听，对应点击调用
    HXAudioInputViewShowTypeWait  //等待
};

typedef NS_ENUM(NSInteger,HXAudioInputViewType)
{
    //短按操作
    HXAudioInputViewWaitType,
    HXAudioInputViewPressSayingType,
    
    //长按操作
    HXAudioInputViewSayingType,
    HXAudioInputViewTouchUpFinishType, //长按录入时，点击 放开结束
    
    HXAudioInputViewDeletingType,
};

typedef void(^AudioBeginBlk)(void);
typedef void(^AudioEndBlk)(void);
typedef void(^AudioCancelBlk)(void);

/// 机器人输入弹窗
@interface HXAudioInputView : UIViewController



/// 输入结束 隐藏， 默认隐藏
@property (nonatomic, assign) BOOL endInputDismiss;

/// 波纹 采用外部音频 数据 setVoiceLevel ，default NO
@property (nonatomic, assign) BOOL audioLevelOutSide;


- (id)init __attribute__((unavailable("init not available, call shareInstance instead")));
- (id)new __attribute__((unavailable("new not available, call shareInstance instead")));

+ (instancetype)shareInstance;

#pragma mark- 外部控制使用

/// 重置
/// @param noResult 是否无结果
- (void)reLisheningFail:(BOOL)noResult;

/// 开始录入
/// @param showType 显示类型
- (void)beginLisheningWithShowType:(HXAudioInputViewShowType)showType;

/// 结束监听
- (void)endListhening;
///外部获取波纹 大小的值 ，audioLevelOutSide YES 才行
- (void)setVoiceLevel:(int)level;


/// 回调
/// @param beginBlk 开始
/// @param endBlk 结束
/// @param cancelBlk 取消
- (void)setBeginBlk:(AudioBeginBlk)beginBlk endBlk:(AudioEndBlk)endBlk cancelBlk:(AudioCancelBlk)cancelBlk;


/// 是否可以输入， 上一波输入结束，或者 当前处于监听状态下
- (BOOL)canSearch;

- (void)showInController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
