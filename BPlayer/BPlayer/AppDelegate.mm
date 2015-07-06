//
//  AppDelegate.m
//  BPlayer
//
//  Created by Bruce on 15/6/27.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "AppDelegate.h"
#import <Platinum/Platinum.h>
#import "UPnPEngine.h"
#import "Util.h"
#import "Macro.h"
#import "CoreFMDB.h"

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
    if(kIS_IPAD){
        RootViewController *root=[[RootViewController alloc]initWithNibName:@"RootView" bundle:nil];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:root];
        self.window.rootViewController=nav;
    }
    else{
        RootViewController *root=[[RootViewController alloc]initWithNibName:@"RootView-iPhone" bundle:nil];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:root];
        self.window.rootViewController=nav;
    }
    
    NSLog(@"window frame:%@",[NSValue valueWithCGRect:self.window.frame]);
    //启动
//    [[MediaServerBrowserService instance] startService];
    //create db
    [self creatFolder];
    [self createDBTable];
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
    NSString *name=[[UIDevice currentDevice] name];
    // **This is quite useless for no document content manage support from UI
//    [[UPnPEngine getEngine] intendStartLocalFileServerWithRootPath:[[Util sharedInstance] getDocumentPath] serverName:@"x1iOSDMS_File"];
    // **
    NSString *serverName=[NSString stringWithFormat:@"%@%@",name,@"_Music"];
    [[UPnPEngine getEngine] intendStartItunesMusicServerWithServerName:serverName];
//    [[UPnPEngine getEngine] intendStartIOSPhotoServerWithServerName:@"x1iOSDMS_Photo"];
    
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
#pragma mark -
#pragma mark MediaServerBrowserDelegate

- (void)mediaServerAdded:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
        [self.serverItems setObject:friendlyName forKey:uuid];
//    _dmsArr=[NSMutableDictionary dictionaryWithDictionary:[[MediaServerBrowserService instance] mediaServers]];
    
}

- (void)mediaServerRemove:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.serverItems removeObjectForKey:uuid];

}
#pragma mark -
-(void)creatFolder{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"player"];

    NSLog(@"---path:%@",path);
    BOOL isDirectory=[fileManager fileExistsAtPath:path isDirectory:nil];
    if(!isDirectory){
        if([fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]==NO){
            NSLog(@"创建文件夹失败");
            [Singleton sharedInstance].cacheDoc=path;
            
            return;
        }
        else{
            [Singleton sharedInstance].cacheDoc=path;
            NSLog(@"创建成功");
        }
    }
    else {
        [Singleton sharedInstance].cacheDoc=path;
        NSLog(@"文件夹存在");
    }
}
- (void)createDBTable{
    //创建音乐表
    BOOL musicBool=[CoreFMDB executeUpdate:@"create table if not exists music(id integer primary key autoIncrement,uri text,title text,size integer,artist text,album text,genres text,date text);"];
    if(musicBool){
        NSLog(@"创建music table success");
    }
    else{
        NSLog(@"创建music table fail");
    }
    
    //创建收藏表
    BOOL favouriteBool=[CoreFMDB executeUpdate:@"create table if not exists favourite(id integer primary key autoIncrement,uri text,title text,size integer,artist text,album text,genres text,date text);"];
    if(favouriteBool){
        NSLog(@"创建favourite table success");
    }
    else{
        NSLog(@"创建favourite table fail");
    }
    //创建播放列表
    BOOL playlistBool=[CoreFMDB executeUpdate:@"create table if not exists playlist(id integer primary key autoIncrement,uri text,title text,size integer,artist text,album text,genres text,date text);"];
    if(playlistBool){
        NSLog(@"创建playlist table success");
    }
    else{
        NSLog(@"创建playlist table fail");
    }
}
@end
