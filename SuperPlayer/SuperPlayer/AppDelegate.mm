//
//  AppDelegate.m
//  SuperPlayer
//
//  Created by Bruce on 15-6-6.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "AppDelegate.h"
#import <Platinum/Platinum.h>
#import "UPnPEngine.h"
#import "Util.h"
#import "Macro.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //初始化dms
    [self initUpnpServer];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationFlag_StatusChanged object:nil];
    //
    RootViewController *root=[[RootViewController alloc]init];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:root];
    self.window.rootViewController=nav;
    
    NSLog(@"window frame:%@",[NSValue valueWithCGRect:self.window.frame]);
    
    
    //
//    MasterViewController *master=[[MasterViewController alloc]initWithNibName:@"MasterViewController" bundle:nil];
//    self.navController= [[UINavigationController alloc]initWithRootViewController:master];
//    self.window.rootViewController=self.navController;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
#pragma mark - upnp methods

- (void)initUpnpServer {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // **This is quite useless for no document content manage support from UI
    [[UPnPEngine getEngine] intendStartLocalFileServerWithRootPath:[[Util sharedInstance] getDocumentPath] serverName:@"xiOSDMS_File"];
    // **
    
    [[UPnPEngine getEngine] intendStartItunesMusicServerWithServerName:@"xiOSDMS_Music"];
    [[UPnPEngine getEngine] intendStartIOSPhotoServerWithServerName:@"xiOSDMS_Photo"];
    
    if (![[UPnPEngine getEngine] startUPnP]) {
        NSLog(@"Error starting up DMS servers");
    }
    else{
        NSLog(@"success starting up dms server");
    }
}


- (void)destroyUpnpServer {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UPnPEngine getEngine] stopUPnP];
}
@end
