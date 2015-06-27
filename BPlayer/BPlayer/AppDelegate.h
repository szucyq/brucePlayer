//
//  AppDelegate.h
//  BPlayer
//
//  Created by Bruce on 15/6/27.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,copy)NSString *serverUuid;
@property (nonatomic,retain)UINavigationController *navController;

@end

