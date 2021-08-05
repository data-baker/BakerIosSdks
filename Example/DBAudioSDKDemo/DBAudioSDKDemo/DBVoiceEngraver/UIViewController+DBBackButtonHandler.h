//
//  UIViewController+DBBackButtonHandler.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/5.
//  Copyright © 2020 biaobei. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
 
@optional
 
/**
 重写下面的方法以拦截导航栏返回按钮点击事件，返回 YES 则 pop，NO 则不 pop
 @return 1:可以返回 0：不可以返回
 */
-(BOOL)navigationShouldPopOnBackButton;
 
@end



@interface UIViewController (DBBackButtonHandler)<BackButtonHandlerProtocol>

@end

