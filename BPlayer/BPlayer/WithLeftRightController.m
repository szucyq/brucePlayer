//
//  WithLeftRightController.m
//  GuanJia
//
//  Created by andone on 14-7-1.
//  Copyright (c) 2014年 andone. All rights reserved.
//

#import "WithLeftRightController.h"

@interface WithLeftRightController ()

@end

@implementation WithLeftRightController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setCustomBackButtonText:(NSString *)backButtonTitle withImgName:(NSString*)sender
{
    //该方法通过指定left bar item，但会导致所有的都出现
    UIButton *bt=[self customButtonWithImgName:sender];
    [bt setTitle:backButtonTitle forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(backToAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
}
- (void)backToAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"此处默认实现返回方法，如果需要实现的是该方法，则无需重写，否则请实现自己navigation bar 左侧按钮的方法");
}
- (void)setCustomRightButtonText:(NSString *)rightButtonTitle withImgName:(NSString*)sender
{
    //该方法通过指定left bar item，但会导致所有的都出现
    UIButton *bt=[self customButtonWithImgName:sender];
    [bt setTitle:rightButtonTitle forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(rightToAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;

}

- (void)rightToAction:(id)sender{
    NSLog(@"实现自己navigation bar 右侧按钮的方法，如果没有实现会出现该提示");
}


- (UIButton*)customButtonWithImgName:(NSString*)sender{
    UIButton *bt=[UIButton buttonWithType:UIButtonTypeCustom];
    [bt setFrame:CGRectMake(0, 0, 30.0, 30.0)];
    bt.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:15.0];
    
    if(![sender length]>0){
        NSLog(@"-----!!!!!no bt img");
        [bt setBackgroundColor:[UIColor blackColor]];
    }
    else{
        NSLog(@"-----!!!!!have bt img");
//        NSString *imgPath=[[NSBundle mainBundle]pathForResource:sender ofType:@"png"];
        [bt setBackgroundImage:[UIImage imageNamed:sender] forState:UIControlStateNormal];
    }
    bt.titleLabel.minimumScaleFactor=6.0f;
    bt.titleLabel.adjustsFontSizeToFitWidth=YES;
    return bt;
}

-  (UIButton*)titleViewWithTitle:(NSString*)sender{
    //title view
    UIButton *titleView=[UIButton buttonWithType:UIButtonTypeCustom];
    [titleView setFrame:CGRectMake(0, 0, 100, 49)];

    [titleView setTitle:sender forState:UIControlStateNormal];
    [titleView addTarget:self action:@selector(navTaped:) forControlEvents:UIControlEventTouchDown];
    return titleView;
}
- (void)navTaped:(id)sender{
    NSLog(@"title view taped");
}
@end
