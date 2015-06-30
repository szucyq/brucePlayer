//
//  RootViewController.m
//  JFPlayer
//
//  Created by Bruce on 15-5-2.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "RootViewController.h"
#import <Platinum/Platinum.h>
#import "AppDelegate.h"

@implementation RootViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    //table view
    self.listTableView.frame=CGRectMake(0, 300, 300, 300);
    self.listTableView.hidden=YES;
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playWithAvItem:) name:@"kPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getServerAction:) name:@"kSelectServer" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}
- (void)viewDidLayoutSubviews{
//    self.navigationController.navigationBarHidden=YES;
    //top view
    self.topView.frame=CGRectMake(0, kContentBaseY, kContentViewWidth-_rightView.frame.size.width, _topView.frame.size.height);
    //right view
    self.rightView.frame=CGRectMake(kContentViewWidth-_rightView.frame.size.width, kContentBaseY, _rightView.frame.size.width, kContentViewHeightNoTab);
    //bottom view
    self.bottomView.frame=CGRectMake(0, self.view.frame.size.height-_bottomView.frame.size.height, kContentViewWidth-_rightView.frame.size.width, _bottomView.frame.size.height);
    NSLog(@"bottom view frame:%@",[NSValue valueWithCGRect:self.bottomView.frame]);
    //all music view && catalog view
    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    self.allMusicController.view.frame=frame;
    self.allMusicController.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    self.catalogNav.view.frame=frame;
    
    

    if(kIS_IPAD){
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation)){
            NSLog(@"横向");
        }
        else{
            NSLog(@"竖屏");
            
        }
    }
    else if(kIS_IPHONE){
        NSLog(@"iphone");
    }
    else{
        NSLog(@"other device");
    }

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    
//}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation)){
//        NSLog(@"横向");
//        
//        return YES;
//    }
//    else if(UIDeviceOrientationIsPortrait(deviceOrientation)) {
//       NSLog(@"纵向");
//        return NO;
//    }
//    else{
//        return NO;
//    }
//    // // Return YES for supported orientations
////    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft); // 只支持向左横向, YES 表示支持所有方向
//}
#pragma mark -
#pragma mark - actions
- (IBAction)renderBtAction:(id)sender {
    self.renderViewController = [[RenderViewController alloc] init];
    
    [self.navigationController pushViewController:self.renderViewController animated:YES];
}

- (IBAction)serverBtAction:(id)sender {
//    self.serverController=[[ServerViewController alloc]init];
    ServerViewController *serverC=[[ServerViewController alloc]init];
    [self.navigationController pushViewController:serverC animated:YES];
//    [self presentViewController:self.serverController animated:YES completion:nil];
}

- (IBAction)loadAllContentsAction:(id)sender {
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithUUID:appDelagete.serverUuid delegate:self];
        [crawler crawl];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (IBAction)settingAction:(id)sender {
    NSLog(@"设置");
    if(kIS_IPAD){
        SettingViewController *setting=[[SettingViewController alloc]init];
        UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:setting];
        popoverController.contentViewController.contentSizeForViewInPopover=CGSizeMake(300, 500);
        
        [popoverController presentPopoverFromRect:self.setupBt.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"iphone 暂不支持该操作" maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (IBAction)catalogBtAction:(id)sender {
    [self bringCatagoryViewToFront];
    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];

    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    
    ServerContentViewController *itemController=[[ServerContentViewController alloc]initWithFrame:frame root:YES objectId:nil];
    //catalogNav视图用于按照目录层级的方式进行访问server资源
    if(self.catalogNav){
        NSLog(@"如果已有目录浏览视图，则先删除");
        [self.catalogNav.view removeFromSuperview];
        
        //add catalog style nav 添加层级目录浏览界面
        
        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
        self.catalogNav.view.frame=frame;
        self.catalogNav.view.tag=10000;
        [self.view addSubview:self.catalogNav.view];
    }
    else{
        NSLog(@"如果没有目录浏览视图，则添加");
        //add catalog style nav 添加层级目录浏览界面
        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
        self.catalogNav.view.frame=frame;
        self.catalogNav.view.tag=10000;
        [self.view addSubview:self.catalogNav.view];
    }
    
    
    
    
}

- (IBAction)listLookAction:(id)sender {
    NSLog(@"列表浏览");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    if(!appDelagete.serverUuid){
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (IBAction)iconLookAction:(id)sender {
    NSLog(@"图标浏览");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    if(!appDelagete.serverUuid){
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (IBAction)bySongAction:(id)sender {
    NSLog(@"按歌曲浏览");
    [self refreshAllMusicByType:@"music"];
    
}

- (IBAction)byZuoquAction:(id)sender {
    NSLog(@"按作曲浏览");
    [self bringAllMusicViewToFront];
    [self refreshAllMusicByType:@"zuoqu"];
}

- (IBAction)byArtistAction:(id)sender {
    NSLog(@"按艺术家浏览");
    [self refreshAllMusicByType:@"artist"];
}

- (IBAction)byAlbumAction:(id)sender {
    NSLog(@"按专辑浏览");
    [self refreshAllMusicByType:@"album"];
}

- (IBAction)preBtAction:(id)sender {
    NSLog(@"上一首");
//    [self.renderer previous];
}

- (IBAction)playPauseBtAction:(id)sender {
    NSLog(@"播放、暂停");
//    if (self.isPlay) {
////        [self.renderer stop];
//        [self.renderer pause];
//        [self.playBt setTitle:@"播放" forState:UIControlStateNormal];
//        
//    }else {
//        [self.renderer play];
//        [self.playBt setTitle:@"暂定" forState:UIControlStateNormal];
//    }
//    self.isPlay = [self.renderer isPlaying];
}

- (IBAction)nextBtAction:(id)sender {
    NSLog(@"下一首");
//    [self.renderer next];
//    [self.renderer setMute:1];
}

- (IBAction)setVolumeAction:(id)sender {
    NSLog(@"音量");
//    [self.renderer setVolume:self.volumeBt.value];
}

- (IBAction)seekAction:(id)sender {
    NSLog(@"进度条控制");
}

- (IBAction)muteAction:(id)sender {
    NSLog(@"静音");
}
//- (BOOL)device:(CGUpnpDevice *)device service:(CGUpnpService *)service actionReceived:(CGUpnpAction *)action
//{
//    NSLog(@"action %@", [action description]);
//    return YES;
//}
- (void)bringAllMusicViewToFront{
    if(self.allMusicController){
        [self.view bringSubviewToFront:self.allMusicController.view];
    }
}
- (void)bringCatagoryViewToFront{
    if(self.catalogNav){
        [self.view bringSubviewToFront:self.catalogNav.view];
    }
}
- (void)refreshAllMusicByType:(NSString*)type{
    //取得当前的server
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *serverUuid=appDelagete.serverUuid;
    if(!serverUuid){
        [SVProgressHUD showErrorWithStatus:@"请先选择一个服务器" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    //刷新当前server内容
    if(self.allMusicController){
        self.allMusicController.serverUuid=serverUuid;
        self.allMusicController.byType=type;

        [self.view bringSubviewToFront:self.allMusicController.view];
    }
    else{
        CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
        self.allMusicController = [[AllMusicController alloc]initWithFrame:frame];
        self.allMusicController.view.frame=frame;
        
        self.allMusicController.serverUuid=serverUuid;
        self.allMusicController.byType=type;
        
        [self.view addSubview:self.allMusicController.view];
    }
}
#pragma mark - notion controls
- (void)playWithAvItem:(NSNotification *)sender{
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    [SVProgressHUD showErrorWithStatus:@"请选择播放器" maskType:SVProgressHUDMaskTypeBlack];
    
}
- (void)getServerAction:(NSNotification *)sender{
//    NSDictionary *userinfo=[sender userInfo];
//    NSString *serverUuid = [userinfo objectForKey:@"server"];
    
//    if(self.allMusicController){
////        self.allMusicController.server=serverUuid;
//        [self.view bringSubviewToFront:self.allMusicController.view];
//    }
//    else{
//        CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
//        self.allMusicController = [[AllMusicController alloc]initWithFrame:frame];
//        self.allMusicController.view.frame=frame;
////        self.allMusicController.server = serverUuid;
//
//        [self.view addSubview:self.allMusicController.view];
//    }
    
    [self bringCatagoryViewToFront];
    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    
    ServerContentViewController *itemController=[[ServerContentViewController alloc]initWithFrame:frame root:YES objectId:nil];

    //catalogNav视图用于按照目录层级的方式进行访问server资源
    if(self.catalogNav){
        NSLog(@"如果已有目录浏览视图，则先删除");
        [self.catalogNav.view removeFromSuperview];
        
        //add catalog style nav 添加层级目录浏览界面
        
        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];

        self.catalogNav.view.frame=frame;
        self.catalogNav.view.tag=10000;
        [self.view addSubview:self.catalogNav.view];
    }
    else{
        NSLog(@"如果没有目录浏览视图，则添加");
        //add catalog style nav 添加层级目录浏览界面
        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
        self.catalogNav.view.frame=frame;
        self.catalogNav.view.tag=10000;
        [self.view addSubview:self.catalogNav.view];
    }
    
}
#pragma mark Media server content crawler delegate
- (void)onCrawlResult:(NSArray *)items{
    NSLog(@"craw items:%@",items);
}
@end

