//
//  AppDelegate.m
//  Dilidili
//
//  Created by iMac on 16/8/23.
//  Copyright © 2016年 BoxingWoo. All rights reserved.
//

#import "AppDelegate.h"
#import "AppInfo.h"
#import "MyCustomLogFormatter.h"
#import "LaunchViewModel.h"
#import "DdTabBarViewModel.h"
#import "BSAlertView.h"

#import "AFNetworkReachabilityManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 日志输出
    [self configLogger];
    
    // 网络监测
    [self monitorNetwork];
    
    // 加载
    [self handleLaunch:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 配置

// 日志输出
- (void)configLogger
{
    // 配置调试日志输出
#ifdef DEBUG
    
//    // 控制台输出染色
//    // ERROR(错误) > 红色
//    // WARN(警告) > 黄色
//    // INFO(信息) > 蓝色
//    // DEBUG(调试）> 黑色
//    setenv("XcodeColors", "YES", 0);
    
    // Xcode console
    [DDTTYLogger sharedInstance].logFormatter = [[MyCustomLogFormatter alloc] init];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
//    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    
#else
    
    // Apple System Logs
    [DDASLLogger sharedInstance].logFormatter = [[MyCustomLogFormatter alloc] init];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
#endif

    DDLogDebug(@"====================dilidili====================");
}

#pragma mark - 加载

// 加载
- (void)handleLaunch:(NSDictionary *)launchOptions
{
    NSString *newestVersion = [AppInfo appVersion];
    NSString *appVersion = [USER_DEFAULTS valueForKey:@"appVersion"];
    if (![newestVersion isEqualToString:appVersion]) {
        [USER_DEFAULTS setValue:newestVersion forKey:@"appVersion"];
        
        // 清除缓存
        YYImageCache *imageCache = [YYImageCache sharedCache];
        [imageCache.diskCache removeAllObjects];
    }
    
    // 如果是第一次启动，使用UserGuideViewController (用户引导页面) 作为根视图
    NSString *shortVersion = [USER_DEFAULTS valueForKey:@"shortVersion"];
    if (!shortVersion || ![newestVersion hasPrefix:shortVersion]) {
        NSArray *versions = [newestVersion componentsSeparatedByString:@"."];
        shortVersion = [NSString stringWithFormat:@"%@.%@", versions[0], versions[1]];
        [USER_DEFAULTS setValue:shortVersion forKey:@"shortVersion"];
        
    }
    
    // 记录启动次数
    NSInteger launchCount = [USER_DEFAULTS integerForKey:@"launchCount"];
    launchCount++;
    DDLogDebug(@"启动次数: %li", launchCount);
    [USER_DEFAULTS setInteger:launchCount forKey:@"launchCount"];
    
    // 加载视图
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = kBgColor;
    
    DdBasedViewModel *viewModel = nil;
#ifdef DEBUG
    viewModel = [[DdTabBarViewModel alloc] initWithClassName:@"DdTabBarController" params:nil];
#else
    viewModel = [[LaunchViewModel alloc] initWithClassName:@"LaunchViewController" params:nil];
#endif
    
    UIViewController *rootVC = [UIViewController initWithViewModel:viewModel];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
}

#pragma mark - 其它

// 网络监测
- (void)monitorNetwork
{
    AFNetworkReachabilityManager *reachablityManager = [AFNetworkReachabilityManager sharedManager];
    [reachablityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DDLogDebug(@"当前网络状态: %@", AFStringFromNetworkReachabilityStatus(status));
        if (status == AFNetworkReachabilityStatusNotReachable) {
            BSAlertView *alertView = [[BSAlertView alloc] initWithTitle:@"提示" message:@"网络不可用，请检查网络设置！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] onButtonTouchUpInside:NULL];
            [alertView show];
        }
    }];
    [reachablityManager startMonitoring];
}

@end
