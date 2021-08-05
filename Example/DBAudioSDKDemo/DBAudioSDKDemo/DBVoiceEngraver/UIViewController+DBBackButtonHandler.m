//
//  UIViewController+DBBackButtonHandler.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/5.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "UIViewController+DBBackButtonHandler.h"

@implementation UIViewController (DBBackButtonHandler)
@end
@implementation UINavigationController (ShouldPopOnBackButton)


- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if([self.viewControllers count] < [navigationBar.items count])
    {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackButton)])
    {
        shouldPop = [vc navigationShouldPopOnBackButton];
    }
    
    if(shouldPop)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    else
    {
        // 取消 pop 后，复原返回按钮的状态
        for(UIView *subview in [navigationBar subviews])
        {
            if(0.0 < subview.alpha && subview.alpha < 1.0)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }
    }
    return NO;
}


@end


