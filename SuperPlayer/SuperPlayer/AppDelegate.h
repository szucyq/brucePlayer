//
//  AppDelegate.h
//  SuperPlayer
//
//  Created by Bruce on 15-6-6.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <Foundation/Foundation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, retain)CGUpnpAvRenderer* avRenderer;
//@property (nonatomic,retain)CGUpnpAvServer *avServer;
@property (nonatomic,retain)UINavigationController *navController;

@end

