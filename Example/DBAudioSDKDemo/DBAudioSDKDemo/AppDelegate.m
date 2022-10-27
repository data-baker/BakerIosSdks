//
//  AppDelegate.m
//  DBASRDemo(002)
//
//  Created by linxi on 2021/2/1.
//

#import "AppDelegate.h"
//#ifdef DEBUG
//#import <DoraemonKit/DoraemonManager.h>
//#import "DoraemonUtil.h"
//#import <DoraemonKit/DoraemonKit.h>
//#import <DoraemonKit/DoraemonAppInfoViewController.h>
//#import "DoraemonTimeProfiler.h"
//#import "DoraemonKitDemoi18Util.h"
//
//#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//#ifdef DEBUG
//    [[DoraemonManager shareInstance] installWithPid:@"749a0600b5e48dd77cf8ee680be7b1b7"];//productId为在“平台端操作指南”中申请的产品id
//    
//    [[DoraemonManager shareInstance] addPluginWithTitle:DoraemonDemoLocalizedString(@"测试插件") icon:@"doraemon_default" desc:DoraemonDemoLocalizedString(@"测试插件") pluginName:@"TestPlugin" atModule:DoraemonDemoLocalizedString(@"业务工具")];
//#endif
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {  
}


@end
