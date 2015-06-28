//
//  WhiteTitle.m
//  iChild
//
//  Created by andone on 13-12-22.
//  Copyright (c) 2013年 andone. All rights reserved.
//

#import "ColorTitle.h"
#import "AppDelegate.h"

@interface ColorTitle ()

@end

@implementation ColorTitle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setSelfTitle:(NSString*)sender{
    UIButton *titleView=[UIButton buttonWithType:UIButtonTypeCustom];
    [titleView setFrame:CGRectMake(0, 0, 200, 49)];
    [titleView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleView setTitle:sender forState:UIControlStateNormal];
    [titleView addTarget:self action:@selector(titleAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView=titleView;
    
}
- (void)titleAction{
    NSLog(@"super title action");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - status bar
//- (BOOL)prefersStatusBarHidden{
//    return NO;
//}
//- (UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}
@end
