//
//  RootViewController.m
//  JFPlayer
//
//  Created by Bruce on 15-5-2.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "RootViewController.h"
#import <Platinum/Platinum.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "MTStatusBarOverlay.h"

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
    //
    displayBottom=YES;
    self.view.backgroundColor=[UIColor whiteColor];
    //初始化播放方式
    _playStyle=Circle;
    [self.playStyleBt setImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
    //初始化颜色
    self.bottomView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bg.png"]];
    self.topView.backgroundColor=RGB(236, 234, 234, 1);
    //默认by方式
    [self.catalogBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.catalogBt setImage:[UIImage imageNamed:@"by_Folder_select.png"] forState:UIControlStateNormal];
    [self.catalogBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //默认浏览方式
//    [self.listIconBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
//    [self.listIconBt setImage:[UIImage imageNamed:@"menu_list_icon_select.png"] forState:UIControlStateNormal];

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
    
    
    //setting通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingAction:) name:@"setting" object:nil];
    //30 s后隐藏视图
    [self beginHideTimer];
    //如果之前有server，则默认同步server资料
    [self initDataIfExistServer];
    
    //添加kvo
    [[MediaRenderControllerService instance] addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [[MediaRenderControllerService instance] addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [[MediaRenderControllerService instance] addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"])
    {
        NSLog(@"state:%@",[[MediaRenderControllerService instance] valueForKey:@"state"]);
    }
    if([keyPath isEqualToString:@"duration"])
    {
        //当前歌曲长度
        NSTimeInterval ti=[[[MediaRenderControllerService instance] valueForKey:@"duration"] doubleValue];
        self.lengthTimeLabel.text=stringFromInterval(ti);
        self.curMusicTimeLabel.text=stringFromInterval(ti);
        
        //进度条
        self.seekSlider.minimumValue = 0;   //最小值
        self.seekSlider.maximumValue = ti;  //最大值
    }
    if([keyPath isEqualToString:@"title"])
    {
        self.curMusicNameLabel.text=[[MediaRenderControllerService instance] valueForKey:@"title"];
    }
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
    
    //right view
    if(kIS_IPHONE){
        self.rightView.frame=CGRectMake(kContentViewWidth-_rightView.frame.size.width, kContentBaseY, _rightView.frame.size.width, kContentViewHeightNoTab);
    }
    //top view
    self.topView.frame=CGRectMake(0, kContentBaseY, kContentViewWidth, _topView.frame.size.height);
    //bottom view
    self.bottomView.frame=CGRectMake(0,_topView.frame.size.height+_topView.frame.origin.y, kContentViewWidth, _bottomView.frame.size.height);
    if(displayBottom){
        //all music view
        CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height+self.bottomView.frame.size.height, kContentViewWidth, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
        NSLog(@"old view frame:%@",[NSValue valueWithCGRect:frame]);
        self.allMusicController.view.frame=frame;
        self.allMusicController.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        //catalog view
        self.catalogNav.view.frame=frame;
    }
    else{
        
        //all music view
        CGRect frame=CGRectMake(0, self.topView.frame.origin.y+self.topView.frame.size.height, kContentViewWidth, self.view.frame.size.height-self.topView.frame.size.height-self.topView.frame.origin.y);
        NSLog(@"new view frame:%@",[NSValue valueWithCGRect:frame]);
        self.allMusicController.view.frame=frame;
        self.allMusicController.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        //catalog view
        self.catalogNav.view.frame=frame;
    }
    
    
    

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

- (void)setNewFrame:(CGRect)frame{
    NSLog(@"new frame:%@",[NSValue valueWithCGRect:frame]);
    //all music view
    self.allMusicController.view.frame=frame;
    self.allMusicController.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    //catalog view
    self.catalogNav.view.frame=frame;
    NSLog(@"all music frame:%@",[NSValue valueWithCGRect:self.allMusicController.view.frame]);
    NSLog(@"cata view frame:%@",[NSValue valueWithCGRect:self.catalogNav.view.frame]);
    [self viewDidLayoutSubviews];
}
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
    
}
- (void)initDataIfExistServer{
//    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//    NSString *uuid=[defaults valueForKey:kDefaultServer];
//    if(uuid){
//        AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//        appDelagete.serverUuid=uuid;
//        [self performSelector:@selector(loadAllContentsAction:) withObject:nil];
//    }
}
#pragma mark -
#pragma 隐藏底部视图
- (void)beginHideTimer{
    if([self.hideTimer isValid]){
        [self.hideTimer invalidate];
    }
    self.secondsCountDown = 1000;//1000秒倒计时
    self.hideTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideTimeFireMethod) userInfo:nil repeats:YES];
}
- (void)hideTimeFireMethod{
    self.secondsCountDown--;
    if(self.secondsCountDown==0){
        [self.hideTimer invalidate];
        displayBottom=YES;
        [self performSelector:@selector(hideBottomAction:) withObject:nil];
    }
    else{
        
        
    }
}
- (IBAction)hideBottomAction:(id)sender {
    //    CGRect frame;
    if(displayBottom){
        self.bottomView.hidden=YES;
        //        frame=CGRectMake(0, self.topView.frame.origin.y+self.topView.frame.size.height, kContentViewWidth, self.view.frame.size.height-self.topView.frame.size.height-self.topView.frame.origin.y);
        
    }
    else{
        //        frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height+self.bottomView.frame.size.height, kContentViewWidth, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
        self.bottomView.hidden=NO;
        [self beginHideTimer];
    }
    displayBottom=!displayBottom;
    //    [self setNewFrame:frame];
    [self viewDidLayoutSubviews];
}
#pragma mark -
#pragma mark - actions
- (IBAction)renderBtAction:(id)sender {
//    self.renderViewController = [[RenderViewController alloc] init];
//    
//    [self.navigationController pushViewController:self.renderViewController animated:YES];
    if(kIS_IPAD){
        if(!self.renderViewController){
            CGRect frame=CGRectMake(0, 0, 300, 300);
            self.renderViewController=[[RenderViewController alloc]initWithFrame:frame];
            self.renderViewController.preferredContentSize=CGSizeMake(300, 300);
        }
        
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
    //--status bar
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
    overlay.detailViewMode = MTDetailViewModeHistory;
    [overlay postMessage:@"资源同步中..." animated:YES];
    overlay.progress = 0.1;
    
    //---
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        MediaServerBrowser *browser=[[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid];

        //
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithBrowser:browser];
        NSLog(@"crawler init");
        [crawler crawl:^(BOOL ret, NSArray *items) {
            NSLog(@"crawler items = %d", [items count]);
            //添加music 数据
            for (int i=0; i<items.count; i++) {
                MediaServerItem *item=[items objectAtIndex:i];
                
                NSString *title=[NSString stringWithFormat:@"%@",item.title];
                NSString *uri=[NSString stringWithFormat:@"%@",item.uri];
                NSString *composer=[NSString stringWithFormat:@"%@",item.composer];
                NSString *album=[NSString stringWithFormat:@"%@",item.album];
                
                NSString *genres=@"";
                for(id obj in item.genres){
                    if(![obj isEqual:[NSNull null]] && obj!=nil){
                        NSString *str;
                        if(genres.length>0){
                            str=[NSString stringWithFormat:@"%@%@",@"/",obj];
                        }
                        else{
                            str=[NSString stringWithFormat:@"%@",obj];
                        }
                        genres=[genres stringByAppendingString:str];
                    }
                    
                }

                //date
//                NSString *date=[NSString stringWithFormat:@"%@",item.date];
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
                dateFormatter.dateFormat= @"yyyy-MM-dd";
//                NSString *date=[dateFormatter stringFromDate:item.date];
//                NSLog(@"date:%@",date);
                //
                NSString *format=[NSString stringWithFormat:@"%@",item.contentFormat];
                //duration
                NSTimeInterval durationDouble=item.duration;
                NSString *duration=[NSString stringWithFormat:@"%f",durationDouble];
                NSLog(@"duration:%f",durationDouble);
                
                 NSString *sql=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"insert into music (server,title,uri,composer,album,genres,date,format,duration) values('",appDelagete.serverUuid,@"','",title,@"','",uri,@"','",composer,@"','",album,@"','",genres,@"','",item.date,@"','",format,@"','",duration,@"');"];
                
                NSLog(@"sql:%@",sql);
                BOOL musicAdd=[CoreFMDB executeUpdate:sql];
                if(musicAdd){
                    NSLog(@"success:%d",i);
                }
                else{
                    NSLog(@"fail:%d",i);
                }
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
                
                NSLog(@"iconURI:%@",item.iconURI);
                
                NSLog(@"duration:%f",item.duration);
                NSLog(@"album:%@",item.album);
                NSLog(@"genres:%@",item.genres);
                NSLog(@"bit:%f",item.bitrate);
                NSLog(@"date:%@",item.date);
            }
            
            [overlay postImmediateFinishMessage:@"资源同步完成!" duration:2.0 animated:YES];
            overlay.progress =1.0;

        }];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (IBAction)favouriteAction:(id)sender {
    NSLog(@"收藏夹，等资源做效果");
    CGRect frame=CGRectMake(0, 0, 300, 300);
    FavoriteListController *favoriteListController=[[FavoriteListController alloc]initWithFrame:frame];
    favoriteListController.preferredContentSize=CGSizeMake(300, 300);
    
    UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:favoriteListController];
    
    [popoverController presentPopoverFromRect:self.favoriteBt.frame inView:self.topView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    //status
//    [self menuNormal];
    
//    [self.favoriteBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
//    [self.favoriteBt setImage:[UIImage imageNamed:@"menu_favourite_select.png"] forState:UIControlStateNormal];
}

- (IBAction)playlistAction:(id)sender {
    NSLog(@"播放列表，等资源做效果");
    CGRect frame=CGRectMake(0, 0, 300, 300);
    PlayListController *playListController=[[PlayListController alloc]initWithFrame:frame];
    playListController.preferredContentSize=CGSizeMake(300, 300);
    
    UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:playListController];
    
    [popoverController presentPopoverFromRect:self.playListBt.frame inView:self.bottomView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    //status
    [self byNormal];
    
    [self.catalogBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.catalogBt setImage:[UIImage imageNamed:@"by_Folder_select.png"] forState:UIControlStateNormal];
    [self.catalogBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //

    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];

    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    NSLog(@"frame:%@",[NSValue valueWithCGRect:frame]);
//    ServerContentViewController *itemController=[[ServerContentViewController alloc]initWithFrame:frame];
    ServerContentViewController *itemController=[[ServerContentViewController alloc]initWithFrame:frame root:YES objectId:nil title:appDelagete.serverUuid];
    //catalogNav视图用于按照目录层级的方式进行访问server资源
    if(self.catalogNav){
        NSLog(@"如果已有目录浏览视图，则先删除");
        for(UIView *view in self.view.subviews){
            if(view.tag==10000){
                [view removeFromSuperview];
            }
        }
//        [self.catalogNav.view removeFromSuperview];
        self.catalogNav=nil;
        
        //add catalog style nav 添加层级目录浏览界面
        
//        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
//        self.catalogNav.view.frame=frame;
//        self.catalogNav.view.tag=10000;
//        [self.view addSubview:self.catalogNav.view];
    }
    else{
        NSLog(@"如果没有目录浏览视图，则添加");
        //add catalog style nav 添加层级目录浏览界面
//        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
//        self.catalogNav.view.frame=frame;
//        self.catalogNav.view.tag=10000;
//        [self.view addSubview:self.catalogNav.view];
    }
    self.catalogNav=[[UINavigationController alloc]initWithRootViewController:itemController];
    self.catalogNav.view.frame=frame;
    self.catalogNav.view.tag=10000;
    [self.view addSubview:self.catalogNav.view];
    
    
    
    
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
    //status
    [self menuNormal];
    
    [self.listBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.listBt setImage:[UIImage imageNamed:@"menu_list_no_icon_select.png"] forState:UIControlStateNormal];
}

- (IBAction)iconLookAction:(id)sender {
    NSLog(@"图标浏览");
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    if(!appDelagete.serverUuid){
//        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
//        return;
//    }
    
    
    [self refreshAllMusicByType:@"icon"];
    //status
    [self menuNormal];
    
    [self.iconBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.iconBt setImage:[UIImage imageNamed:@"menu_icon_select.png"] forState:UIControlStateNormal];
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
    //status
    [self menuNormal];
    
    [self.listIconBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.listIconBt setImage:[UIImage imageNamed:@"menu_list_icon_select.png"] forState:UIControlStateNormal];
}



- (IBAction)remoteControlAction:(id)sender {
    RemoteControlController *remote=[[RemoteControlController alloc]init];
    [self presentModalViewController:remote animated:YES];

    
}

- (IBAction)byDateAction:(id)sender {
    NSLog(@"按日期浏览");
    [self refreshAllMusicByType:@"date"];
    //status
    [self byNormal];
    
    [self.dateBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.dateBt setImage:[UIImage imageNamed:@"by_Years_select.png"] forState:UIControlStateNormal];
    [self.dateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (IBAction)bySongAction:(id)sender {
    NSLog(@"按歌曲浏览");
    [self refreshAllMusicByType:@"music"];
    //status
    [self byNormal];
    
    [self.songBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.songBt setImage:[UIImage imageNamed:@"by_Songs_select.png"] forState:UIControlStateNormal];
    [self.songBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)byZuoquAction:(id)sender {
    NSLog(@"按作曲浏览");

    [self refreshAllMusicByType:@"zuoqu"];
    //status
    [self byNormal];
    
    [self.genresBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.genresBt setImage:[UIImage imageNamed:@"by_Genres_select.png"] forState:UIControlStateNormal];
    [self.genresBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)byArtistAction:(id)sender {
    NSLog(@"按艺术家浏览");
    [self refreshAllMusicByType:@"artist"];
    //status
    [self byNormal];
    
    [self.artistBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.artistBt setImage:[UIImage imageNamed:@"by_Artists_select.png"] forState:UIControlStateNormal];
    [self.artistBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)byAlbumAction:(id)sender {
    NSLog(@"按专辑浏览");
    [self refreshAllMusicByType:@"album"];
    //status
    [self byNormal];
    
    [self.zhuanjiBt setBackgroundImage:[UIImage imageNamed:@"by_bg_blue.png"] forState:UIControlStateNormal];
    [self.zhuanjiBt setImage:[UIImage imageNamed:@"by_Albums_select.png"] forState:UIControlStateNormal];
    [self.zhuanjiBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)byNormal{
    NSString *bgName=@"by_bg_gray.png";
    //song
    [self.songBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.songBt setImage:[UIImage imageNamed:@"by_Songs.png"] forState:UIControlStateNormal];
    [self.songBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //album
    [self.zhuanjiBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.zhuanjiBt setImage:[UIImage imageNamed:@"by_Albums.png"] forState:UIControlStateNormal];
    [self.zhuanjiBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //artist
    [self.artistBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.artistBt setImage:[UIImage imageNamed:@"by_Artists.png"] forState:UIControlStateNormal];
    [self.artistBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     //genres
    [self.genresBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.genresBt setImage:[UIImage imageNamed:@"by_Genres.png"] forState:UIControlStateNormal];
    [self.genresBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //years
    [self.dateBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.dateBt setImage:[UIImage imageNamed:@"by_Years.png"] forState:UIControlStateNormal];
    [self.dateBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //folder
    [self.catalogBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.catalogBt setImage:[UIImage imageNamed:@"by_Folder.png"] forState:UIControlStateNormal];
    [self.catalogBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}
- (void)menuNormal{
    NSString *bgName=@"by_bg_gray.png";
    //favourite
    [self.favoriteBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.favoriteBt setImage:[UIImage imageNamed:@"menu_favourite.png"] forState:UIControlStateNormal];
    //icon
    [self.iconBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.iconBt setImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
    //list
    [self.listIconBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.listIconBt setImage:[UIImage imageNamed:@"menu_list_icon.png"] forState:UIControlStateNormal];
    //list-no-icon
    [self.listBt setBackgroundImage:[UIImage imageNamed:bgName] forState:UIControlStateNormal];
    [self.listBt setImage:[UIImage imageNamed:@"menu_list_no_icon.png"] forState:UIControlStateNormal];
}
#pragma mark -
- (IBAction)preBtAction:(id)sender {
    NSLog(@"上一首");
    [self initRender];
    [self.render previous:^(BOOL value){
        NSLog(@"previous:%d",value);
        if(value){
            [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
                if(value){
                    NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
                    [self refreshCurrentMusicInfoWithItem:item];
                }
            }];
            
            
        }
        NSString *str=[NSString stringWithFormat:@"%d",value];
        [self alert:@"上一首提示" msg:str];
    }];
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
        NSString *str=[NSString stringWithFormat:@"%d",value];
        [self alert:@"下一首提示" msg:str];
    }];
    
    
}
- (IBAction)getVolumeAction:(id)sender {
    NSLog(@"获取音量");
    [self initRender];
    [self.render getVolume:^(BOOL value,NSInteger volume){
        NSLog(@"value:%d--volume:%d",value,volume);
        self.volumeBt.value=volume;
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
//- (IBAction)getCurPosAction:(id)sender {
//    NSLog(@"获取当前位置");
//    [self initRender];
//    [self.render getCurPos:^(BOOL value,NSTimeInterval time){
//        NSLog(@"当前位置:%f",time);
//        //刷新当前时间
////        [self refreshCurrentMusicTime:nil time:nil];
//    }];
//}

- (IBAction)playStyleAction:(id)sender {
    if(_playStyle==Single){
        _playStyle=Playlist;
        [self.playStyleBt setImage:[UIImage imageNamed:@"play_list.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Playlist){
        _playStyle=Circle;
        [self.playStyleBt setImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Circle){
        _playStyle=Random;
        [self.playStyleBt setImage:[UIImage imageNamed:@"play_random.png"] forState:UIControlStateNormal];
    }
    else if(_playStyle==Random){
        _playStyle=Single;
        [self.playStyleBt setImage:[UIImage imageNamed:@"play_single.png"] forState:UIControlStateNormal];
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
            NSString *str=[NSString stringWithFormat:@"%d",value];
            [self alert:@"静音提示" msg:str];
        }];
    }
    else{
        NSLog(@"转静音");
        [self.render setMute:YES handler:^(BOOL value){
            NSLog(@"mute:%d",value);
            [self.muteBt setTitle:@"原音" forState:UIControlStateNormal];
            displayMute=!displayMute;
            NSString *str=[NSString stringWithFormat:@"%d",value];
            [self alert:@"静音提示" msg:str];
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
#pragma mark - refresh music info
- (void)refreshCurrentMusicInfoWithItem:(MediaItemInfo*)item{
    //名字
    self.curMusicNameLabel.text=item.title;
    //格式
    self.curMusicFormatLabel.text=item.extention;
    //比特率
    self.curMusicBitLabel.text=[NSString stringWithFormat:@"%ld",item.bitRate];
    //播放按钮旁边－当前歌曲长度
    self.curMusicTimeLabel.text=stringFromInterval(item.duration);//
    //进度条右侧－当前item长度
    self.lengthTimeLabel.text=stringFromInterval(item.duration);
    
    self.curMusicNameLabel.text=item.title;
    //格式
    self.curMusicFormatLabel.text=item.extention;
    //比特率
    self.curMusicBitLabel.text=[NSString stringWithFormat:@"%ld",item.bitRate];
    
    //slider
    self.seekSlider.minimumValue = 0;   //最小值
    self.seekSlider.maximumValue = item.duration;  //最大值
    self.lengthTimeLabel.text=stringFromInterval(item.duration);
    self.seekSlider.value=0;
}
- (void)refreshCurrentMusicItem:(MediaItemInfo*)item curTime:(NSString*)time{
    
    //当前时间进度
    self.curTimeLabel.text=time;
    
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
    NSLog(@"iconURI:%@",item.iconURI);
    
    NSLog(@"duration:%f",item.duration);
    NSLog(@"album:%@",item.album);
    NSLog(@"genres:%@",item.genres);
    NSLog(@"bit:%f",item.bitrate);
    

    //test begin
    
//    NSURL *fileURL=[NSURL fileURLWithPath:item.uri];
//    AVURLAsset *mp3Asset=[AVURLAsset URLAssetWithURL:fileURL options:nil];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSDictionary *dictAtt = [fm attributesOfItemAtPath:item.uri error:nil];
//    
//    NSString *singer;//歌手
//    NSString *artworker;//作曲家
//    
//    NSString *song;//歌曲名
//    UIImage *image;//图片
//    NSString *albumName;//专辑名
//    NSString *fileSize;//文件大小
//    //    NSString *voiceStyle;//音质类型
//    //    NSString *fileStyle;//文件类型
//    NSString *creatDate;//创建日期
//    
//    fileSize = [NSString stringWithFormat:@"%.2fMB",[[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024)];
//    NSString *tempStrr  = [NSString stringWithFormat:@"%@", [dictAtt objectForKey:@"NSFileCreationDate"]] ;
////    creatDate = [tempStrr substringToIndex:19];
//    
//    //    NSString *savePath; //存储路径  creationDate software
//    //        NSLog(@"---------%@",[mp3Asset availableMetadataFormats]);
//    for (NSString *format in [mp3Asset availableMetadataFormats]) {
//        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
//            
//            //                NSLog(@"metadataItem is %@",[mp3Asset metadataForFormat:format]);
//            if([metadataItem.commonKey isEqualToString:@"title"]){
//                song = (NSString *)metadataItem.value;//歌曲名
//            }else if ([metadataItem.commonKey isEqualToString:@"artist"]){
//                singer = (NSString *)metadataItem.value;//歌手
//            }
//            else if ([metadataItem.commonKey isEqualToString:@"duration"]){
//                NSString*  duration = (NSString *)metadataItem.value;//歌手
//                                    NSLog(@"+++++++++duration is %@",duration);
//            }
//            else if ([metadataItem.commonKey isEqualToString:@"software"]){
//                NSString*  software = (NSString *)metadataItem.value;//歌手
//                //                    NSLog(@"+++++++++software is %@",software);
//            }
//            
//            //            专辑名称
//            else if ([metadataItem.commonKey isEqualToString:@"albumName"])
//            {
//                albumName = (NSString *)metadataItem.value;
//                                    NSLog(@"albumName is %@",albumName);
//            }else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
//                artworker = (NSString *)metadataItem.value;
//                
//                NSData *data=(NSData *)metadataItem.value;
//                image=[UIImage imageWithData:data];//图片
//            }
//            
//        }
//    }
//    
//    
//    NSDictionary *singrecord=[[NSDictionary alloc]initWithObjectsAndKeys:song,@"title", singer, @"artist", albumName, @"albumName", image, @"albumimage", fileSize,@"fileSize" ,creatDate,@"creatDate",nil];
//    NSLog(@"record:%@",singrecord);
    //test end
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *renderUuid=appDelagete.renderUuid;
    if([renderUuid isEqualToString:@"self"]){
        MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:item.uri]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        return;
    }
    

    //播放
    [self initRender];
    [self.render setUri:item.uri name:item.title handler:^(BOOL ret){
        if(ret){
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!ret = %d", ret);
            //play
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
                if(ret){
                    [self.playBt setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                    //刷新当前播放音乐的显示信息
                    [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
                        if(value){
                            NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
                            [self refreshCurrentMusicInfoWithItem:item];
                        }
                    }];
                    
                    //timer
                    if([self.playTimer isValid]){
                        [self.playTimer invalidate];
                    }
                    self.playTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                }
            }];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"该文件播放错误，请重试" maskType:SVProgressHUDMaskTypeBlack];
            return ;
        }
    }];
    
    
    
    
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

    [self.render getCurPos:^(BOOL value,NSTimeInterval time,NSTimeInterval duration){
        NSLog(@"getCurPos:%f---duration:%f",time,duration);
    
        //该方法应该主要刷新当前时间进度，不用做其他变化信息的处理
//        self.seekSlider.minimumValue = 0;   //最小值
//        self.seekSlider.maximumValue = duration;  //最大值
//        self.lengthTimeLabel.text=stringFromInterval(duration);
//        self.curMusicTimeLabel.text=stringFromInterval(duration);
        self.seekSlider.value=time;//每秒刷新进度条显示
        
        NSString *timeStr=stringFromInterval(time);
        [self refreshCurrentMusicItem:nil curTime:timeStr];//每秒刷新进度label显示
        
        [self getVolumeAction:nil];//每秒刷新音量
        
        //歌曲信息变化时应该由kvo||getMediaInfo来触发，不用放此处
    
//        [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
//            if(value){
//                NSLog(@"getMediaInfo curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
//                
//            }
//            
//            //刷新当前时间
//            NSString *timeStr=stringFromInterval(time);
//            [self refreshCurrentMusicItem:item curTime:timeStr];
//            //刷新当前歌曲信息－自动切换歌曲、prevous、next时需要用到该方法
//            [self refreshCurrentMusicInfoWithItem:item];
//            //刷新音量
//            [self getVolumeAction:nil];
//        }];
        
    }];
    
}
- (void)getServerAction:(NSNotification *)sender{

    //左侧消失
    [self restoreViewLocation];
    //
    CGRect frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height-kContentBaseY);
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
    
    ServerContentViewController *contentController=[[ServerContentViewController alloc]initWithFrame:frame root:YES objectId:nil title:appDelagete.serverUuid];

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
//    [SVProgressHUD showInfoWithStatus:@"正在为您同步资源" maskType:SVProgressHUDMaskTypeBlack];
    [self performSelector:@selector(loadAllContentsAction:) withObject:nil];
}
#pragma mark -
#pragma mark MediaServerBrowserDelegate

- (void)mediaServerAdded:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    NSLog(@"dms msg:%@",msg);
    NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.dmsDic setObject:msg forKey:uuid];
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.dmsDic,@"server", nil];
    NSLog(@"servers add:%@",[MediaServerBrowserService instance].mediaServers);
//     NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[MediaServerBrowserService instance].mediaServers,@"server", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftRefresh" object:nil userInfo:dic];
}

- (void)mediaServerRemove:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.dmsDic removeObjectForKey:uuid];
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.dmsDic,@"server", nil];
    NSLog(@"servers Remove:%@",[MediaServerBrowserService instance].mediaServers);
//    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[MediaServerBrowserService instance].mediaServers,@"server", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftRefresh" object:nil userInfo:dic];
}
@end

