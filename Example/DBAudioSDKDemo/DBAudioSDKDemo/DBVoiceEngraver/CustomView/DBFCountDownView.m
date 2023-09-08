//
//  DBFCountDownView.m
//  Biaobei
//
//  Created by biaobei on 2022/6/21.
//  Copyright © 2022 标贝科技. All rights reserved.
//

#import "DBFCountDownView.h"
#import "UIView+Factory_hzj.h"
#import "NSTimer+BlocksSupport.h"

@interface DBFCountDownView ()
{
    NSTimer *_timer;
}

@property(nonatomic,strong)UIView * backView;
@property(nonatomic,strong)UILabel * countDownLabel;





@end


@implementation DBFCountDownView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backView];
        [self addSubview:self.countDownLabel];
        self.layer.cornerRadius = 4.f;
        self.layer.masksToBounds = YES;
        [self layoutUI];
        [self hiddenView];
    }
    return self;
}

- (void)layoutUI {
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(kFitSize(119+20));
        make.height.mas_equalTo(kFitSize(125+20));
    }];
    
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(kFitSize(119));
        make.height.mas_equalTo(kFitSize(125));
    }];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}
// MARK: Public Method

- (void)hiddenView {
    self.hidden = YES;
    self.countDownLabel.text = @"";
}
- (void)showViewWithIsStart:(BOOL)isStart completeHandler:(dispatch_block_t)handler {
    NSAssert(handler, @"请设置handler");
    __block NSInteger countDownCount = 2;
  
    NSString *preText;
    if (isStart) {
        preText = @"请保持安静，倒计时结束后开始录制";
    }else {
        preText = @"采集完成，倒计时期间请保持安静";
    }
    NSString *allText = [NSString stringWithFormat:@"%@\n%@",preText, @(countDownCount)];
    [self showWithText:allText rangeText:@(countDownCount).stringValue];
    _timer = [NSTimer bs_scheduledTimerWithTimeInterval:1 block:^{
        countDownCount--;
        if(countDownCount == 0) {
            [self hiddenView];
            if(self->_timer) {
                [self->_timer invalidate];
            }
            handler();
            return;
        }
        NSString *allText = [NSString stringWithFormat:@"%@\n%@",preText, @(countDownCount)];
        [self showWithText:allText rangeText:@(countDownCount).stringValue];
        
    } repeats:YES];
}


- (void)showWithText:(NSString *)text rangeText:(NSString *)rangeText {
    self.hidden = NO;
    self.countDownLabel.attributedText = [self setupCountDownText:text rangeText:rangeText];
}


- (UIView *)backView {
    if (!_backView) {
        UIView *view = [UIView viewBackGroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
        _backView = view;
    }
    return _backView;
}

- (UILabel *)countDownLabel {
    if (!_countDownLabel) {
        _countDownLabel = [[UILabel alloc]init];
        _countDownLabel.font = [UIFont systemFontOfSize:14];
        _countDownLabel.textAlignment = NSTextAlignmentCenter;
        _countDownLabel.textColor = [UIColor whiteColor];
        _countDownLabel.numberOfLines = 0;
        _countDownLabel.backgroundColor = [UIColor clearColor];
    }
    return _countDownLabel;
}

- (NSAttributedString *)setupCountDownText:(NSString *)allText rangeText:(NSString *)rangeText {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:allText];
    NSRange range = [allText rangeOfString:rangeText];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:70] range:range];
    return attributeString;
}


@end
