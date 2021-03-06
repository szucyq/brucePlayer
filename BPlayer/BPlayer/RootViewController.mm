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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playWithChooseItem:) name:@"kPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getServerAction:) name:@"kSelectServer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRenderAction:) name:@"kSelectRender" object:nil];
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
    
    
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"state"])
    {
        NSLog(@"state:%@",[self.render valueForKey:@"state"]);
        
        if([[self.render valueForKey:@"state"] intValue]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                //playing
                [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
                    if(value){
                        NSLog(@"getMediaInfo curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
                        [self refreshCurrentMusicInfoWithItem:item];
                    }
                }];
            });
        }
    }
    if([keyPath isEqualToString:@"duration"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //当前歌曲长度
            NSTimeInterval ti=[[self.render valueForKey:@"duration"] doubleValue];
            self.lengthTimeLabel.text=stringFromInterval(ti);
            self.curMusicTimeLabel.text=stringFromInterval(ti);
            
            //进度条
            self.seekSlider.minimumValue = 0;   //最小值
            self.seekSlider.maximumValue = ti;  //最大值
            self.seekSlider.value=0;
        });
        
    }
    if([keyPath isEqualToString:@"title"])
    {
        NSLog(@"title:%@",[self.render valueForKey:@"title"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.curMusicNameLabel.text=[self.render valueForKey:@"title"];
        });
        
        NSLog(@"title 2:%@",self.curMusicNameLabel.text);
    }
    if([keyPath isEqualToString:@"volume"])
    {
        NSLog(@"volume:%@",[self.render valueForKey:@"volume"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger volume=[[self.render valueForKey:@"volume"] integerValue];
            self.volumeBt.value=volume;
        });
        

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
        if(!self.render){
            self.render=[[MediaRenderControllerService instance] controllerWithUUID:renderUuid];
        }
        
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
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self performSelector:@selector(loadAllContentsAction:) withObject:nil];
//        });
//        
//    }
}
#pragma mark -
#pragma mark - 隐藏底部视图
- (void)beginHideTimer{
    if([self.hideTimer isValid]){
        [self.hideTimer invalidate];
    }
    self.secondsCountDown = 10000;//1000秒倒计时后隐藏
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
                
                
                
                if(item.albumArtURI.length>0){
                    NSLog(@"albumArtURI:%@",item.albumArtURI);
                }
                if(item.iconURI.length>0){
                    NSLog(@"iconURI:%@",item.iconURI);
                }
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


#pragma mark -
#pragma mark - 浏览方式
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
#pragma mark - 上一首｜下一首｜播放暂停｜进度条｜音量｜播放模式
- (IBAction)preBtAction:(id)sender {
    NSLog(@"上一首");
    [self initRender];
    [self.render stop:^(BOOL value){
        if(value){
            [self nextSongNumber:NO];
            //
            AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
            int curSongNum=appDelagete.curMusicNumber;
            if(self.tempItemsArray.count>curSongNum){
                MediaServerItem *item=[self.tempItemsArray objectAtIndex:curSongNum];
                //播放
                [self playWithNextItem:item];
                
            }
        }
    }];
//    [self.render previous:^(BOOL value){
//        NSLog(@"previous:%d",value);
//        if(value){
//            [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
//                if(value){
//                    NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
//                    [self refreshCurrentMusicInfoWithItem:item];
//                }
//            }];
//            
//            
//        }
//        NSString *str=[NSString stringWithFormat:@"%d",value];
//        [self alert:@"上一首提示" msg:str];
//    }];
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
    [self.render stop:^(BOOL value){
        NSLog(@"stop:%d",value);
        if(value){
            [self nextSongNumber:YES];
            AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
            int curSongNum=appDelagete.curMusicNumber;
            NSLog(@"temp count:%d---cur num:%d",self.tempItemsArray.count,curSongNum);
            if(self.tempItemsArray.count>curSongNum){
                MediaServerItem *item=[self.tempItemsArray objectAtIndex:curSongNum];
                NSLog(@"next item;%@",item);
                //播放
                [self playWithNextItem:item];

            }
        }
    }];
//    [self.render next:^(BOOL value){
//        NSLog(@"next:%d",value);
//        if(value){
//            [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
//                if(value){
//                    NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
//                    [self refreshCurrentMusicInfoWithItem:item];
//                }
//            }];
//            
//            
//        }
//        NSString *str=[NSString stringWithFormat:@"%d",value];
//        [self alert:@"下一首提示" msg:str];
//    }];
    
    
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
    [self initRender];
    
    if(_playStyle==Single){
//        _playStyle=Playlist;
//        [self.playStyleBt setImage:[UIImage imageNamed:@"play_list.png"] forState:UIControlStateNormal];
        [self.render setPlayMode:ORDER_PLAY handler:^(BOOL ret){
            if(ret){
                _playStyle=Playlist;
                [self.playStyleBt setImage:[UIImage imageNamed:@"play_list.png"] forState:UIControlStateNormal];
            }
        }];
    }
    else if(_playStyle==Playlist){
//        _playStyle=Circle;
//        [self.playStyleBt setImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
        [self.render setPlayMode:CIRCULATE_PLAY handler:^(BOOL ret){
            if(ret){
                _playStyle=Circle;
                [self.playStyleBt setImage:[UIImage imageNamed:@"play_circle.png"] forState:UIControlStateNormal];
            }
        }];
        
    }
    else if(_playStyle==Circle){
//        _playStyle=Random;
//        [self.playStyleBt setImage:[UIImage imageNamed:@"play_random.png"] forState:UIControlStateNormal];
        [self.render setPlayMode:RANDOM_PLAY handler:^(BOOL ret){
            if(ret){
                _playStyle=Random;
                [self.playStyleBt setImage:[UIImage imageNamed:@"play_random.png"] forState:UIControlStateNormal];
            }
        }];
        
    }
    else if(_playStyle==Random){
//        _playStyle=Single;
//        [self.playStyleBt setImage:[UIImage imageNamed:@"play_single.png"] forState:UIControlStateNormal];
        [self.render setPlayMode:SINGLE_CIRCULATE handler:^(BOOL ret){
            if(ret){
                _playStyle=Single;
                [self.playStyleBt setImage:[UIImage imageNamed:@"play_single.png"] forState:UIControlStateNormal];
            }
        }];
        
    }
    
}

- (IBAction)seekAction:(id)sender {
    NSLog(@"进度条控制:%f",self.seekSlider.value);
    if([self.playTimer isValid]){
        [self.playTimer invalidate];
    }
    
    [self initRender];
    NSTimeInterval time=self.seekSlider.value;
    [self.render seek:time handler:^(BOOL value){
        NSLog(@"进度条控制 value:%d",value);
        if(value){
            //
            [self performSelector:@selector(initTimer) withObject:nil afterDelay:1.0];


        }
    }];

}
- (void)initTimer{
    self.playTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
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
- (void)nextSongNumber:(BOOL)sender{
//    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//    int curSongNum=[[defaults valueForKey:kCurSongNumber] intValue];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    int curSongNum=appDelagete.curMusicNumber;
    
//    NSMutableArray *array=[self allMusicDataArray];
    [self.tempItemsArray removeAllObjects];
    self.tempItemsArray=[self allMusicDataArray];
    if(!self.tempItemsArray){
        return;
    }
    
    if (_playStyle==Single)
    {
        curSongNum=curSongNum;
    }
    else if (_playStyle==Playlist)
    {
        if(sender){
            if (curSongNum==self.tempItemsArray.count-1)
            {
                if([self.playTimer isValid]){
                    [self.playTimer invalidate];
                }
                sleep(5);
                exit(0);
            }
            else
            {
                curSongNum++;
            }
        }
        else{
            if (curSongNum==0)
            {
                if([self.playTimer isValid]){
                    [self.playTimer invalidate];
                }
                sleep(5);
                exit(0);
            }
            else
            {
                curSongNum--;
            }
        }
        
    }
    else if (_playStyle==Circle)
    {
        if(sender){
            if (curSongNum==self.tempItemsArray.count-1)
            {
                curSongNum=0;
            }
            else
            {
                curSongNum++;
            }
        }
        else{
            if (curSongNum==0)
            {
                curSongNum=self.tempItemsArray.count-1;
            }
            else
            {
                curSongNum--;
            }
        }
        
    }
    else if (_playStyle==Random){
        curSongNum=rand()%(self.tempItemsArray.count);
        NSLog(@"随机%d",curSongNum);
    }
    
    appDelagete.curMusicNumber=curSongNum;
//    [defaults setValue:[NSNumber numberWithInt:curSongNum] forKey:kCurSongNumber];
//    [defaults synchronize];
}
- (NSMutableArray*)allMusicDataArray{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    if(!appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        return nil;
    }
    
    NSLog(@"server uuid :%@",appDelagete.serverUuid);
    NSMutableArray *array=[NSMutableArray array];
    
    NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"select * from music where server='",appDelagete.serverUuid,@"';"];
    //    NSString *sql=[NSString stringWithFormat:@"%@",@"select * from music;"];
    //查询数据
    [CoreFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            NSLog(@"%@-%@",[set stringForColumn:@"title"],[set stringForColumn:@"uri"]);
            //date
            NSString *dateStr=[set stringForColumn:@"date"];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
            dateFormatter.dateFormat= @"yyyy-MM-dd";
            NSDate *date=[dateFormatter dateFromString:dateStr];
            NSLog(@"date:%@",date);
            //duration
            NSString *durationStr=[set stringForColumn:@"duration"];
            NSTimeInterval duration=[durationStr floatValue];
            
            
            MediaServerItem *item=[[MediaServerItem alloc]init];
            item.title=[set stringForColumn:@"title"];
            item.uri=[set stringForColumn:@"uri"];
            item.composer=[set stringForColumn:@"composer"];
//            item.date=date;
            item.album=[set stringForColumn:@"album"];
            //            item.contentFormat=[set stringForColumn:@"genres"];
            item.artist=[set stringForColumn:@"artist"];
            item.duration=duration;
            NSArray *gArray=[NSArray arrayWithObject:[set stringForColumn:@"genres"]];
            item.genres=gArray;
            
            [array addObject:item];
        }
        
    }];
    
    return array;

}
- (void)playWithNextItem:(MediaServerItem *)item{
//    NSLog(@"objID:%@",item.objID);
//    NSLog(@"title:%@",item.title);
//    NSLog(@"uri:%@",item.uri);
//    NSLog(@"size:%lu",(unsigned long)item.size);
//    NSLog(@"type:%d",item.type);
//    NSLog(@"artist:%@",item.artist);
//    NSLog(@"date:%@",item.date);
//    NSLog(@"composer:%@",item.composer);
//    NSLog(@"trackList:%@",item.trackList);
//    NSLog(@"codeType:%@",item.codeType);
//    NSLog(@"contentFormat:%@",item.contentFormat);
//    NSLog(@"mimeType:%@",item.mimeType);
//    NSLog(@"extention:%@",item.extention);
//    NSLog(@"albumArtURI:%@",item.albumArtURI);
//    NSLog(@"iconURI:%@",item.iconURI);
//    
//    NSLog(@"duration:%f",item.duration);
//    NSLog(@"album:%@",item.album);
//    NSLog(@"genres:%@",item.genres);
//    NSLog(@"bit:%f",item.bitrate);
    
    
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *renderUuid=appDelagete.renderUuid;
    if([renderUuid isEqualToString:@"self"]){
        MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:item.uri]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        return;
    }
    
    
    //播放
    [self.render setUri:item.uri name:item.title handler:^(BOOL ret){
        if(ret){
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!ret = %d", ret);
            //play
            [self.render play:^(BOOL ret){
                NSLog(@"play:%d",ret);
                if(ret){
                    [self.playBt setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                    
                    //timer
                    if(![self.playTimer isValid]){
                        self.playTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                    }
                    
                    
                }
            }];
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"该文件播放错误，请重试" maskType:SVProgressHUDMaskTypeBlack];
            return ;
        }
    }];
    
    
    
    
}
#pragma mark - refresh music info
- (void)refreshCurrentMusicInfoWithItem:(MediaItemInfo*)item{
    //格式
    self.curMusicFormatLabel.text=item.extention;
    //比特率
    self.curMusicBitLabel.text=[NSString stringWithFormat:@"%ld",item.bitRate];
    
    //slider
    self.seekSlider.minimumValue = 0;   //最小值
//    self.seekSlider.maximumValue = item.duration;  //最大值
//    self.lengthTimeLabel.text=stringFromInterval(item.duration);
    
    //名字
    self.curMusicNameLabel.text=item.title;
    //播放按钮旁边－当前歌曲长度
    self.curMusicTimeLabel.text=stringFromInterval(item.duration);//
    //进度条右侧－当前歌曲长度
    self.lengthTimeLabel.text=stringFromInterval(item.duration);
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
#pragma mark -
#pragma mark - play   notificationon
- (void)playWithChooseItem:(NSNotification *)sender{
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
                    
                    //timer
                    if(![self.playTimer isValid]){
                        self.playTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
                    }
                    
                    
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
    //获取当前进度
    [self.render getCurPos:^(BOOL value,NSTimeInterval time,NSTimeInterval duration){
        NSLog(@"getCurPos:%f---duration:%f",time,duration);
    
        //该方法应该主要刷新当前时间进度，不用做其他变化信息的处理
        if(value){
            self.seekSlider.value=time;//每秒刷新进度条显示
            self.seekSlider.maximumValue = duration;  //最大值
            self.lengthTimeLabel.text=stringFromInterval(duration);//slider右侧时间显示
            self.curTimeLabel.text=stringFromInterval(time);//slider 左侧时间显示
        }
        
    }];
    //获取当前文件信息
    [self.render getMediaInfo:^(BOOL value,MediaItemInfo *item){
        if(value){
            NSLog(@"curUrl:%@,title:%@,icon:%@,duration:%f",item.curUrl,item.title,item.iconUri,item.duration);
            [self refreshCurrentMusicInfoWithItem:item];
        }
    }];
    
    //获取当前音量
    [self.render getVolume:^(BOOL value,NSInteger volume){
        NSLog(@"value:%d--volume:%d",value,volume);
        self.volumeBt.value=volume;
    }];

    
}
#pragma mark -
#pragma mark - server   notificationon
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
#pragma mark - render   notificationon
- (void)getRenderAction:(NSNotification *)sender{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *renderUuid=appDelagete.renderUuid;
    NSLog(@"uuid:%@",renderUuid);
    self.render=[[MediaRenderControllerService instance] controllerWithUUID:renderUuid];
    [self.render getStat:^(BOOL value,int status){
        
    }];
    
    //添加kvo
//    [self.render addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    [self.render addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    [self.render addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    [self.render addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    //选择render后，同步当前设备数据
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

