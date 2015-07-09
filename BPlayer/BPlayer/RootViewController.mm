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

#define kLeftViewWidth 150
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
//    self.listTableView.frame=CGRectMake(0, 300, 300, 300);
//    self.listTableView.hidden=YES;
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playWithAvItem:) name:@"kPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getServerAction:) name:@"kSelectServer" object:nil];
    //启动查找服务器
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServerAdded:)
                                                 name:@"MediaServerAddedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServerRemove:)
                                                 name:@"MediaServerRemovedNotification"
                                               object:nil];
    [[MediaServerBrowserService instance] startService];
    self.dmsDic=[NSMutableDictionary dictionary];
    //首页左右滑动手势
    //---swip left
    UISwipeGestureRecognizer *swipLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    swipLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipLeft];

    
    //--swip right
    UISwipeGestureRecognizer *swipRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
    [self.view addGestureRecognizer:swipRight];

}
- (void)gestureAction:(UIGestureRecognizer *)sender{
    if([sender isKindOfClass:[UISwipeGestureRecognizer class]]){
        NSLog(@"轻扫");
        UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
        switch (direction) {
            case UISwipeGestureRecognizerDirectionUp:
                NSLog(@"up");
                break;
            case UISwipeGestureRecognizerDirectionDown:
                NSLog(@"down");
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                NSLog(@"left");
                [self leftAction];
                break;
            case UISwipeGestureRecognizerDirectionRight:
                NSLog(@"right");
                [self rightAction];
                break;
            default:
                break;
        }
    }
    
}
- (void)leftAction{
    NSLog(@"left action");

    if(self.serverController){
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:0.3f];
        
        CGRect rect=CGRectMake(-kLeftViewWidth, kContentBaseY, kLeftViewWidth, self.view.frame.size.height);
        self.serverController.view.frame=rect;

        [UIView commitAnimations];
        NSLog(@"server frame 2:%@",[NSValue valueWithCGRect:self.serverController.view.frame]);
    }
    
}
- (void)rightAction{
    NSLog(@"right action");
    
    if(self.serverController){
        NSLog(@"已经有server controller");
    }
    else{
        self.serverController=[[ServerViewController alloc]initWithDevices:self.dmsDic frame:CGRectMake(-kLeftViewWidth, kContentBaseY, kLeftViewWidth, kContentViewHeightNoTab)];
        
        [self.view addSubview:self.serverController.view];
        
        
    }
    
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.3f];
    
    CGRect rect=CGRectMake(0,kContentBaseY,kLeftViewWidth,self.view.frame.size.height);
    self.serverController.view.frame=rect;
    
    [UIView commitAnimations];
    
    
    
    
    NSLog(@"server frame 1:%@",[NSValue valueWithCGRect:self.serverController.view.frame]);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}
- (void)viewDidLayoutSubviews{
//    self.navigationController.navigationBarHidden=YES;
    //top view
    self.topView.frame=CGRectMake(0, kContentBaseY, kContentViewWidth, _topView.frame.size.height);
    //right view
    if(kIS_IPHONE){
        self.rightView.frame=CGRectMake(kContentViewWidth-_rightView.frame.size.width, kContentBaseY, _rightView.frame.size.width, kContentViewHeightNoTab);
    }
    
    //bottom view
    self.bottomView.frame=CGRectMake(0,_topView.frame.size.height+_topView.frame.origin.y, kContentViewWidth, _bottomView.frame.size.height);
    NSLog(@"bottom view frame:%@",[NSValue valueWithCGRect:self.bottomView.frame]);
    //all music view && catalog view
    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height+self.bottomView.frame.size.height, kContentViewWidth, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
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

- (void)initRender{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *renderUuid=appDelagete.renderUuid;
    if(renderUuid){
//        if(!self.render){
//            self.render=[[MediaRenderControllerService instance] controllerWithUUID:renderUuid];
//        }
        self.render=[[MediaRenderControllerService instance] controllerWithUUID:renderUuid];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请选择播放器" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
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
//    self.renderViewController = [[RenderViewController alloc] init];
//    
//    [self.navigationController pushViewController:self.renderViewController animated:YES];
    if(kIS_IPAD){
        CGRect frame=CGRectMake(0, 0, 300, 300);
        self.renderViewController=[[RenderViewController alloc]initWithFrame:frame];
        self.renderViewController.preferredContentSize=CGSizeMake(300, 300);
        UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:self.renderViewController];
//        popoverController.contentViewController.contentSizeForViewInPopover=CGSizeMake(300, 500);
        
        [popoverController presentPopoverFromRect:self.renderBt.frame inView:self.bottomView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (IBAction)serverBtAction:(id)sender {
//    self.serverController=[[ServerViewController alloc]init];
    ServerViewController *serverC=[[ServerViewController alloc] initWithDevices:self.dmsDic frame:self.view.bounds];
    [self.navigationController pushViewController:serverC animated:YES];
//    [self presentViewController:self.serverController animated:YES completion:nil];
}

- (IBAction)loadAllContentsAction:(id)sender {
    NSLog(@"加载所有资源，等资源做效果");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        MediaServerBrowser *browser=[[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid];

        //
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithBrowser:browser];
        [crawler crawl:^(BOOL ret, NSArray *items) {
            NSLog(@"crawler items = %@", items);
            //添加music 数据
            for (int i=0; i<items.count; i++) {
                MediaServerItem *item=[items objectAtIndex:i];
                
                NSString *title=[NSString stringWithFormat:@"%@",item.title];
                NSString *uri=[NSString stringWithFormat:@"%@",item.uri];
                NSString *album=[NSString stringWithFormat:@"%@",item.albumArtURI];
                NSString *genres=[NSString stringWithFormat:@"%@",item.mimeType];
                NSString *date=[NSString stringWithFormat:@"%@",item.date];
                NSString *sql=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@",@"insert into music (title,uri,album,genres,date) values('",title,@"','",uri,@"','",album,@"','",genres,@"','",date,@"')"];
                NSLog(@"sql:%@",sql);
                BOOL musicAdd=[CoreFMDB executeUpdate:sql];
                if(musicAdd){
                    NSLog(@"success:%d",i);
                }
                else{
                    NSLog(@"fail:%d",i);
                }
            }
        }];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (IBAction)favouriteAction:(id)sender {
    NSLog(@"收藏夹，等资源做效果");
}

- (IBAction)playlistAction:(id)sender {
    NSLog(@"播放列表，等资源做效果");
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

- (IBAction)searchAction:(id)sender {
    SearchViewController *search=[[SearchViewController alloc]init];
    [self.navigationController pushViewController:search animated:YES];
}

- (IBAction)searchDevicesAction:(id)sender {
    NSLog(@"dms:%@",self.dmsDic);
    if(kIS_IPAD){
        ServerViewController *server=[[ServerViewController alloc]initWithDevices:self.dmsDic frame:CGRectMake(0, 0, 300, 300)];
        server.preferredContentSize=CGSizeMake(300, 300);
        UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:server];
//        popoverController.contentViewController.contentSizeForViewInPopover=CGSizeMake(300, 300);
        
        [popoverController presentPopoverFromRect:self.deviceBt.frame inView:self.bottomView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"iphone 暂不支持该操作" maskType:SVProgressHUDMaskTypeBlack];
    }
}



- (IBAction)catalogBtAction:(id)sender {

    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];

    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    
    ServerContentViewController *itemController=[[ServerContentViewController alloc]initWithFrame:frame];
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
    NSLog(@"按作曲浏览");
    
    [self refreshAllMusicByType:@"list"];
}

- (IBAction)iconLookAction:(id)sender {
    NSLog(@"图标浏览");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    if(!appDelagete.serverUuid){
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    NSLog(@"按作曲浏览");
    
    [self refreshAllMusicByType:@"icon"];
}
- (IBAction)listIconAction:(id)sender {
    NSLog(@"列表－图标浏览");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    if(!appDelagete.serverUuid){
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    NSLog(@"按作曲浏览");
    
    [self refreshAllMusicByType:@"list_icon"];
}

- (IBAction)hideBottomAction:(id)sender {
}

- (IBAction)remoteControlAction:(id)sender {
}
- (IBAction)bySongAction:(id)sender {
    NSLog(@"按歌曲浏览");
    [self refreshAllMusicByType:@"music"];
    
}

- (IBAction)byZuoquAction:(id)sender {
    NSLog(@"按作曲浏览");

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


#pragma mark -
- (IBAction)preBtAction:(id)sender {
    NSLog(@"上一首");
//    [self.renderer previous];
}

- (IBAction)playPauseBtAction:(id)sender {
    NSLog(@"播放、暂停");
    [self initRender];
    [self.render getStat:^(BOOL value,int status){
        if(status==0){
            NSLog(@"stoped");
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
            }];
        }
        else if(status==1){
            NSLog(@"PLAYING");
            [self.render pause:^(BOOL value){
                NSLog(@"pause:%d",value);
            }];
        }
        else if(status==2){
            NSLog(@"PAUSED");
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
            }];
        }
        else if(status==3){
            NSLog(@"LOADING");
        }
        
    }];
    
    
}

- (IBAction)nextBtAction:(id)sender {
    NSLog(@"下一首");
//    [self.renderer next];
//    [self.renderer setMute:1];
}
- (IBAction)getVolumeAction:(id)sender {
    NSLog(@"获取音量");
    [self initRender];
    [self.render getVolume:^(BOOL value,NSInteger volume){
        NSLog(@"value:%d--volume:%ld",value,volume);
    }];
}


- (IBAction)setVolumeAction:(id)sender {
    
    [self initRender];
    int volume=[[NSString stringWithFormat:@"%f",self.volumeBt.value] intValue];
    NSLog(@"音量:%f--%d",self.volumeBt.value,volume);
    [self.render setVolume:volume handler:^(BOOL value){
        NSLog(@"volume :%d",value);
    }];
}
- (IBAction)getCurPosAction:(id)sender {
    NSLog(@"获取当前位置");
    [self initRender];
    [self.render getCurPos:^(BOOL value,NSTimeInterval time){
        NSLog(@"当前位置:%f",time);
    }];
}
- (IBAction)seekAction:(id)sender {
    NSLog(@"进度条控制");
    [self initRender];
    NSTimeInterval time;
    [self.render seek:time handler:^(BOOL value){
        
    }];

}

- (IBAction)muteAction:(id)sender {
    NSLog(@"静音");
    [self initRender];
    [self.render setMute:YES handler:^(BOOL value){
        NSLog(@"mute:%d",value);
    }];
}
//- (BOOL)device:(CGUpnpDevice *)device service:(CGUpnpService *)service actionReceived:(CGUpnpAction *)action
//{
//    NSLog(@"action %@", [action description]);
//    return YES;
//}
//- (void)bringAllMusicViewToFront{
//    if(self.allMusicController){
//        [self.view bringSubviewToFront:self.allMusicController.view];
//    }
//}
//- (void)bringCatagoryViewToFront{
//    if(self.catalogNav){
//        [self.view bringSubviewToFront:self.catalogNav.view];
//    }
//}
- (void)refreshAllMusicByType:(NSString*)type{
    //取得当前的server
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *serverUuid=appDelagete.serverUuid;
//    if(!serverUuid){
//        [SVProgressHUD showErrorWithStatus:@"请先选择一个服务器" maskType:SVProgressHUDMaskTypeBlack];
//        return;
//    }
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
#pragma mark - notificationon controls
- (void)playWithAvItem:(NSNotification *)sender{
    NSDictionary *userinfo=[sender userInfo];
    MediaServerItem *item = [userinfo objectForKey:@"item"];
    NSLog(@"objID:%@",item.objID);
    NSLog(@"title:%@",item.title);
    NSLog(@"uri:%@",item.uri);
    NSLog(@"size:%lu",(unsigned long)item.size);
    NSLog(@"type:%d",item.type);
    NSLog(@"artist:%@",item.artist);
    NSLog(@"date:%@",item.date);
    NSLog(@"composer:%@",item.composer);
    NSLog(@"trackList:%@",item.trackList);
    NSLog(@"codeType:%@",item.codeType);
    NSLog(@"contentFormat:%@",item.contentFormat);
    NSLog(@"mimeType:%@",item.mimeType);
    NSLog(@"extention:%@",item.extention);
    NSLog(@"albumArtURI:%@",item.albumArtURI);
    NSLog(@"thumbnailUrl:%@",item.thumbnailUrl);
    NSLog(@"smallImageUrl:%@",item.smallImageUrl);
    NSLog(@"mediumImageUrl:%@",item.mediumImageUrl);
    NSLog(@"largeImageUrl:%@",item.largeImageUrl);
    

    [self initRender];
    [self.render setUri:item.uri name:@"name" handler:^(BOOL ret){
        if(ret){
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!ret = %d", ret);
        }
    }];
    
    [self.render play:^(BOOL ret){
        NSLog(@"play:%d",ret);
    }];
    
}
- (void)getServerAction:(NSNotification *)sender{

    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    
    ServerContentViewController *contentController=[[ServerContentViewController alloc]initWithFrame:frame root:YES objectId:nil];

    //catalogNav视图用于按照目录层级的方式进行访问server资源
    if(self.catalogNav){
        NSLog(@"如果已有目录浏览视图，则先删除");
        [self.catalogNav.view removeFromSuperview];
        
        //add catalog style nav 添加层级目录浏览界面
        
        
    }
    else{
        NSLog(@"如果没有目录浏览视图，则添加");
        //add catalog style nav 添加层级目录浏览界面
//        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:contentController];
//        self.catalogNav.view.frame=frame;
//        self.catalogNav.view.tag=10000;
//        [self.view addSubview:self.catalogNav.view];
    }
    self.catalogNav=[[UINavigationController alloc]initWithRootViewController:contentController];
    
    self.catalogNav.view.frame=frame;
    self.catalogNav.view.tag=10000;
    [self.view addSubview:self.catalogNav.view];
    [self.view sendSubviewToBack:self.catalogNav.view];
    //提醒开始同步该服务器资源
    [self performSelector:@selector(loadAllContentsAction:) withObject:nil];
}
#pragma mark -
#pragma mark MediaServerBrowserDelegate

- (void)mediaServerAdded:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.dmsDic setObject:friendlyName forKey:uuid];
    //    _dmsArr=[NSMutableDictionary dictionaryWithDictionary:[[MediaServerBrowserService instance] mediaServers]];
    
//    [self.listTableView reloadData];
}

- (void)mediaServerRemove:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.dmsDic removeObjectForKey:uuid];
//    [self.listTableView reloadData];
}
@end

