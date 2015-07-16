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

static BOOL displayBottom=YES;
static BOOL displayMute=NO;

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
    //初始化播放方式
    _playStyle=Circle;
    [self.playStyleBt setBackgroundImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
    //初始化颜色
    self.bottomView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bg.png"]];
    self.topView.backgroundColor=RGB(236, 234, 234, 1);
    

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
    
    //
    displayBottom=YES;
    //setting通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingAction:) name:@"setting" object:nil];

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

//- (void)rightAction{
//    NSLog(@"right action");
//    
//    if(self.serverController){
//        NSLog(@"已经有server controller");
//    }
//    else{
//        self.serverController=[[ServerViewController alloc]initWithDevices:self.dmsDic frame:CGRectMake(-kLeftViewWidth, kContentBaseY, kLeftViewWidth, kContentViewHeightNoTab)];
//        
//        [self.view addSubview:self.serverController.view];
//        
//        
//    }
//    
//    
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:0.3f];
//    
//    CGRect rect=CGRectMake(0,kContentBaseY,kLeftViewWidth,self.view.frame.size.height);
//    self.serverController.view.frame=rect;
//    
//    [UIView commitAnimations];
//    
//    
//    
//    
//    NSLog(@"server frame 1:%@",[NSValue valueWithCGRect:self.serverController.view.frame]);
//}
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
        
        [popoverController presentPopoverFromRect:self.renderBt.frame inView:self.bottomView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else{
        self.renderViewController=[[RenderViewController alloc]initWithFrame:CGRectMake(0, 0, kContentViewWidth, kContentViewHeightNoTab)];
        [self.navigationController pushViewController:self.renderViewController animated:YES];
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
                NSString *composer=[NSString stringWithFormat:@"%@",item.composer];
                NSString *album=[NSString stringWithFormat:@"%@",item.albumArtURI];
                NSString *genres=[NSString stringWithFormat:@"%@",item.mimeType];
                NSString *date=[NSString stringWithFormat:@"%@",item.date];
                NSString *sql=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"insert into music (server,title,uri,composer,album,genres,date) values('",appDelagete.serverUuid,@"','",title,@"','",uri,@"','",composer,@"','",album,@"','",genres,@"','",date,@"')"];
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

- (void)settingAction:(NSNotification*)sender {
    NSLog(@"设置");
    NSDictionary *userinfo=[sender userInfo];
    NSString *display=[userinfo valueForKey:@"setting"];
    if([display isEqualToString:@"1"]){
        NSLog(@"display:%@",display);
        self.settingController=[[SettingController alloc]initWithNibName:@"SettingController" bundle:nil];
        self.settingController.view.frame=self.view.frame;
        [self.view addSubview:self.settingController.view];
    }
    else{
        NSLog(@"else display:%@",display);
        if(self.settingController){
            [self.settingController.view removeFromSuperview];
            self.settingController=nil;
        }
        
    }
//    if(kIS_IPAD){
//        SettingViewController *setting=[[SettingViewController alloc]init];
//        UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:setting];
//        popoverController.contentViewController.contentSizeForViewInPopover=CGSizeMake(300, 500);
//        
//        [popoverController presentPopoverFromRect:self.setupBt.frame inView:self.rightView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
//    }
//    else{
//        [SVProgressHUD showErrorWithStatus:@"iphone 暂不支持该操作" maskType:SVProgressHUDMaskTypeBlack];
//    }
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
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    if(!appDelagete.serverUuid){
//        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
//        return;
//    }
    NSLog(@"按作曲浏览");
    
    [self refreshAllMusicByType:@"list"];
}

- (IBAction)iconLookAction:(id)sender {
    NSLog(@"图标浏览");
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    if(!appDelagete.serverUuid){
//        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
//        return;
//    }
    
    
    [self refreshAllMusicByType:@"icon"];
}
- (IBAction)listIconAction:(id)sender {
    NSLog(@"列表－图标浏览");
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    if(!appDelagete.serverUuid){
//        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
//        return;
//    }
    NSLog(@"按作曲浏览");
    
    [self refreshAllMusicByType:@"list_icon"];
}

- (IBAction)hideBottomAction:(id)sender {
    if(displayBottom){
        self.bottomView.hidden=YES;
    }
    else{
        self.bottomView.hidden=NO;
    }
    displayBottom=!displayBottom;
    
}

- (IBAction)remoteControlAction:(id)sender {
    RemoteControlController *remote=[[RemoteControlController alloc]init];
    [self presentModalViewController:remote animated:YES];
}

- (IBAction)byDateAction:(id)sender {
    NSLog(@"按日期浏览");
    [self refreshAllMusicByType:@"date"];
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
    [self initRender];
    [self.render previous:^(BOOL value){
        NSLog(@"previous:%d",value);
    }];
    [self refreshCurrentMusicInfoWithItem:nil];
}

- (IBAction)playPauseBtAction:(id)sender {
    NSLog(@"播放、暂停");
    [self initRender];
    [self.render getStat:^(BOOL value,int status){
        if(status==0){
            NSLog(@"stoped");
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
                if(ret){
                    [self.playBt setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                }
            }];
        }
        else if(status==1){
            NSLog(@"PLAYING");
            [self.render pause:^(BOOL value){
                NSLog(@"pause:%d",value);
                if(value){
                    [self.playBt setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                }
            }];
        }
        else if(status==2){
            NSLog(@"PAUSED");
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
                if(ret){
                    [self.playBt setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                }
            }];
        }
        else if(status==3){
            NSLog(@"LOADING");
        }
        
    }];
    
    
}

- (IBAction)nextBtAction:(id)sender {
    NSLog(@"下一首");
    [self initRender];
    [self.render next:^(BOOL value){
        NSLog(@"next:%d",value);
        if(value){
            [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
                if(value){
                    NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
                    [self refreshCurrentMusicInfoWithItem:item];
                }
            }];
            
            
        }
    }];
    
    
}
- (IBAction)getVolumeAction:(id)sender {
    NSLog(@"获取音量");
    [self initRender];
    [self.render getVolume:^(BOOL value,NSInteger volume){
        NSLog(@"value:%d--volume:%d",value,volume);
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
        //刷新当前时间
//        [self refreshCurrentMusicTime:nil time:nil];
    }];
}

- (IBAction)playStyleAction:(id)sender {
    if(_playStyle==Single){
        _playStyle=Playlist;
        [self.playStyleBt setBackgroundImage:[UIImage imageNamed:@"play_list.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Playlist){
        _playStyle=Circle;
        [self.playStyleBt setBackgroundImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Circle){
        _playStyle=Random;
        [self.playStyleBt setBackgroundImage:[UIImage imageNamed:@"play_random.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Random){
        _playStyle=Single;
        [self.playStyleBt setBackgroundImage:[UIImage imageNamed:@"play_single.png"] forState:UIControlStateNormal];
    }
    
}
- (IBAction)seekAction:(id)sender {
    NSLog(@"进度条控制:%f",self.seekSlider.value);
    [self initRender];
    NSTimeInterval time=self.seekSlider.value;
    [self.render seek:time handler:^(BOOL value){
        NSLog(@"进度条控制 value:%d",value);
        if(value){
            self.seekSlider.value=time;
        }
    }];

}

- (IBAction)muteAction:(id)sender {
    
    [self initRender];
    if(displayMute){
        NSLog(@"转正常音量");
        [self.render setMute:NO handler:^(BOOL value){
            NSLog(@"mute:%d",value);
            [self.muteBt setTitle:@"静音" forState:UIControlStateNormal];
            displayMute=!displayMute;
        }];
    }
    else{
        NSLog(@"转静音");
        [self.render setMute:YES handler:^(BOOL value){
            NSLog(@"mute:%d",value);
            [self.muteBt setTitle:@"原音" forState:UIControlStateNormal];
            displayMute=!displayMute;
        }];
    }
    
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
- (void)refreshCurrentMusicInfoWithItem:(MediaItemInfo*)item{
    //名字
    self.curMusicNameLabel.text=item.title;
    //格式
    self.curMusicFormatLabel.text=@"mp3";
    //比特率
    self.curMusicBitLabel.text=[NSString stringWithFormat:@"%ld",item.bitRate];
    //当前播放时间进度
    self.curMusicTimeLabel.text=@"00:00:00";//定时刷新显示
    //当前歌曲长度
    self.lengthTimeLabel.text=stringFromInterval(item.duration);//长度
}
- (void)refreshCurrentMusicItem:(MediaItemInfo*)item curTime:(NSString*)time{
    //当前歌曲信息
    [self refreshCurrentMusicInfoWithItem:item];
    //当前时间进度
    self.curMusicTimeLabel.text=time;
    self.curTimeLabel.text=time;
    
}
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
#pragma mark - Swip Left Right
- (void)restoreViewLocation {
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] makeLeftViewUnVisible];
    [UIView animateWithDuration:0.3
                     animations:^{
                        
                         [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.view setFrame:CGRectMake(0, 0, kContentViewWidth, kContentViewHeightNoTab)];
                     }
                     completion:^(BOOL finished){
                         UIControl *overView = (UIControl *)[[[[UIApplication sharedApplication] delegate] window] viewWithTag:10086];
                         [overView removeFromSuperview];
                         
                     }];
}
// animate home view to side rect
- (void)animateHomeViewToSide:(CGRect)newViewRect {
    CGRect oldFrame=[[[UIApplication sharedApplication] delegate] window].rootViewController.view.frame;
    NSLog(@"old rect:%@",[NSValue valueWithCGRect:oldFrame]);
    NSLog(@"new rect:%@",[NSValue valueWithCGRect:newViewRect]);
    [UIView animateWithDuration:0.2
                     animations:^{
                         [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.view setFrame:newViewRect];
                     }
                     completion:^(BOOL finished){
//                         UIControl *overView = [[UIControl alloc] init];
//                         overView.tag = 10086;
//                         overView.backgroundColor = [UIColor clearColor];
//                         overView.frame=[(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController.view.frame;
//                         NSLog(@"-------key window:%@",[[[UIApplication sharedApplication] delegate] window]);
//                         [overView addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
//                         [[[[UIApplication sharedApplication] delegate] window] addSubview:overView];

                     }];
}
- (void)rightAction{
    NSLog(@"swipRightAction");

    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] makeLeftViewVisible];
    [self animateHomeViewToSide:CGRectMake(kLeftViewWidth,
                                           0,
                                           kContentViewWidth,
                                           kContentViewHeightNoTab)];
    

}
- (void)leftAction{
    NSLog(@"left action");
    [self restoreViewLocation];
    //    if(self.serverController){
    //
    //        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    //        [UIView setAnimationDuration:0.3f];
    //
    //        CGRect rect=CGRectMake(-kLeftViewWidth, kContentBaseY, kLeftViewWidth, self.view.frame.size.height);
    //        self.serverController.view.frame=rect;
    //
    //        [UIView commitAnimations];
    //        NSLog(@"server frame 2:%@",[NSValue valueWithCGRect:self.serverController.view.frame]);
    //    }
    
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
    


    //播放
    [self initRender];
    [self.render setUri:item.uri name:@"name" handler:^(BOOL ret){
        if(ret){
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!ret = %d", ret);
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"该文件播放错误，请重试" maskType:SVProgressHUDMaskTypeBlack];
            return ;
        }
    }];
    //play
    [self.render play:^(BOOL ret){
        NSLog(@"play:%d",ret);
    }];
    
    //刷新当前播放音乐的显示信息
    //名字
    self.curMusicNameLabel.text=item.title;
    //格式
    self.curMusicFormatLabel.text=@"mp3";
    //比特率
    self.curMusicBitLabel.text=[NSString stringWithFormat:@"%ld",item.bitrate];
    //当前播放时间进度
    self.curMusicTimeLabel.text=@"00:00:00";//定时刷新显示
    //当前歌曲长度
    self.lengthTimeLabel.text=stringFromInterval(item.duration);//长度
    //slider
    self.seekSlider.minimumValue = 0;   //最小值
    self.seekSlider.maximumValue = item.duration;  //最大值
    self.lengthTimeLabel.text=stringFromInterval(item.duration);
    self.seekSlider.value=0;
    
    //timer
    if([self.playTimer isValid]){
        [self.playTimer invalidate];
    }
    self.playTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
}
NSString *stringFromInterval(NSTimeInterval timeInterval)
{
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
//    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}
-(void)timeFireMethod{

    [self.render getCurPos:^(BOOL value,NSTimeInterval time){
        NSLog(@"当前位置:%f",time);
    
        //----应该在play时修改slider，目前没有时间属性先显示这里
    
        [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
            if(value){
                NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
                self.seekSlider.minimumValue = 0;   //最小值
                self.seekSlider.maximumValue = item.duration;  //最大值
                self.lengthTimeLabel.text=stringFromInterval(item.duration);
            }
            self.seekSlider.value=time;
            //刷新当前时间
            NSString *timeStr=stringFromInterval(time);
            
            [self refreshCurrentMusicItem:item curTime:timeStr];
        }];
        
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
    }
    else{
        NSLog(@"如果没有目录浏览视图，则添加");
    }
    self.catalogNav=[[UINavigationController alloc]initWithRootViewController:contentController];
    
    self.catalogNav.view.frame=frame;
    self.catalogNav.view.tag=10000;
    [self.view addSubview:self.catalogNav.view];
    [self.view bringSubviewToFront:self.catalogNav.view];
    //提醒开始同步该服务器资源
    [SVProgressHUD showInfoWithStatus:@"正在为您同步资源" maskType:SVProgressHUDMaskTypeBlack];
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
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.dmsDic,@"server", nil];
//    [self.listTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftRefresh" object:nil userInfo:dic];
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

