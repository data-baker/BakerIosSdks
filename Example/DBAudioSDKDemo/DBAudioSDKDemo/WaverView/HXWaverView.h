//
//  HXWaverView.h
//  HXWaverView
//
//  Created by kevinzhow on 14/12/14.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HXWaverView : UIView

@property (nonatomic, copy) void (^waverLevelCallback)(HXWaverView * waver);

//

@property (nonatomic) NSUInteger numberOfWaves;

@property (nonatomic) UIColor * waveColor;

@property (nonatomic) CGFloat level;

@property (nonatomic) CGFloat mainWaveWidth;

@property (nonatomic) CGFloat decorativeWavesWidth;

@property (nonatomic) CGFloat idleAmplitude; //怠速

@property (nonatomic) CGFloat frequency; //频率

@property (nonatomic, readonly) CGFloat amplitude; //振幅

@property (nonatomic) CGFloat density; //密度

@property (nonatomic) CGFloat phaseShift; //相移

//

@property (nonatomic, readonly) NSMutableArray * waves;

@end
