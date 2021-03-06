//
//  AppDelegate.h
//  BPlayer
//
//  Created by Bruce on 15/6/27.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MediaServerBrowserService/MediaServerBrowserService.h>
#import "ServerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,copy)NSString *serverUuid;
@property (nonatomic,copy)NSString *renderUuid;
@property (nonatomic)int curMusicNumber;
@property (nonatomic,retain)UINavigationController *navController;
@property (nonatomic,retain)NSMutableDictionary *serverItems;
@property (nonatomic,retain)ServerViewController *leftView;
- (void)makeLeftViewVisible;
- (void)makeLeftViewUnVisible;
@end

