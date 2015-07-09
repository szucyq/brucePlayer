//
//  RootViewController.h
//  JFPlayer
//
//  Created by Bruce on 15-5-2.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WithTableViewController.h"
#import "SettingViewController.h"

#import "RenderViewController.h"
#import <MediaServerBrowserService/MediaServerBrowserService.h>
#import <MediaServerBrowserService/MediaServerCrawler.h>
#import <MediaServerBrowserService/MediaRenderControllerService.h>

#import "ServerViewController.h"

//#import "ServerContentController.h"
#import "ServerContentViewController.h"

#import "AllMusicController.h"
#import "CoreFMDB.h"
#import "SearchViewController.h"

@interface RootViewController : WithLeftRightController

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
//顶端控件
@property (weak, nonatomic) IBOutlet UIButton *zhuanjiBt;
@property (weak, nonatomic) IBOutlet UIButton *artistBt;
@property (weak, nonatomic) IBOutlet UIButton *composerBt;
@property (weak, nonatomic) IBOutlet UIButton *songBt;
@property (weak, nonatomic) IBOutlet UIButton *catalogBt;
@property (weak, nonatomic) IBOutlet UILabel *curSong;
@property (weak, nonatomic) IBOutlet UIButton *iconBt;
@property (weak, nonatomic) IBOutlet UIButton *listBt;

//右侧控件
@property (weak, nonatomic) IBOutlet UIButton *renderBt;
@property (weak, nonatomic) IBOutlet UIButton *serverBt;
//底部控件

@property (weak, nonatomic) IBOutlet UISlider *volumeBt;
@property (weak, nonatomic) IBOutlet UIButton *preBt;
@property (weak, nonatomic) IBOutlet UIButton *playBt;
@property (weak, nonatomic) IBOutlet UIButton *nextBt;
@property (weak, nonatomic) IBOutlet UIButton *setupBt;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
@property (weak, nonatomic) IBOutlet UIButton *muteBt;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deviceBt;

//其他
//@property (nonatomic,retain)ServerContentViewController *serverContentView;
@property (nonatomic,retain)RenderViewController *renderViewController;
@property (nonatomic,retain)ServerViewController *serverController;
@property (nonatomic,retain)UINavigationController *catalogNav;
@property (nonatomic) BOOL isPlay;
@property (nonatomic,retain)NSMutableDictionary* dmsDic;
@property (nonatomic,retain)AllMusicController *allMusicController;
@property (nonatomic,retain)MediaRenderController *render;
//右侧actions
- (IBAction)renderBtAction:(id)sender;
- (IBAction)serverBtAction:(id)sender;
- (IBAction)loadAllContentsAction:(id)sender;
- (IBAction)favouriteAction:(id)sender;
- (IBAction)playlistAction:(id)sender;

//底部actions
- (IBAction)preBtAction:(id)sender;
- (IBAction)playPauseBtAction:(id)sender;
- (IBAction)nextBtAction:(id)sender;
- (IBAction)setVolumeAction:(id)sender;
- (IBAction)seekAction:(id)sender;
- (IBAction)muteAction:(id)sender;
- (IBAction)settingAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)searchDevicesAction:(id)sender;
- (IBAction)getVolumeAction:(id)sender;
- (IBAction)getCurPosAction:(id)sender;

//顶端actions
- (IBAction)catalogBtAction:(id)sender;
- (IBAction)listLookAction:(id)sender;
- (IBAction)iconLookAction:(id)sender;
- (IBAction)bySongAction:(id)sender;
- (IBAction)byZuoquAction:(id)sender;
- (IBAction)byArtistAction:(id)sender;
- (IBAction)byAlbumAction:(id)sender;
- (IBAction)listIconAction:(id)sender;
- (IBAction)hideBottomAction:(id)sender;
- (IBAction)remoteControlAction:(id)sender;

@end