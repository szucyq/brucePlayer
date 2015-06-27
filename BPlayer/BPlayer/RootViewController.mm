//
//  RootViewController.m
//  JFPlayer
//
//  Created by Bruce on 15-5-2.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "RootViewController.h"
#import <Platinum/Platinum.h>

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
- (void)viewDidLayoutSubviews{
    self.navigationController.navigationBarHidden=YES;
    //top view
    self.topView.frame=CGRectMake(0, kContentBaseY, kContentViewWidth-_rightView.frame.size.width, _topView.frame.size.height);
    //right view
    self.rightView.frame=CGRectMake(kContentViewWidth-_rightView.frame.size.width, kContentBaseY, _rightView.frame.size.width, kContentViewHeightNoTab);
    //bottom view
    self.bottomView.frame=CGRectMake(0, self.view.frame.size.height-_bottomView.frame.size.height, kContentViewWidth-_rightView.frame.size.width, _bottomView.frame.size.height);
    NSLog(@"bottom view frame:%@",[NSValue valueWithCGRect:self.bottomView.frame]);
    //顶端subviews
//    int topNum=7;
//    float titleWidth=140;
//    float itemWidth=50;
//    float padding=(kContentViewWidth-titleWidth-topNum*itemWidth)/(topNum+1+1);

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)){
        NSLog(@"横向");
    }
    else{
        NSLog(@"竖屏");

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


#pragma mark -
#pragma mark table view datasource
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.dataSource count];
//    return 5;
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"renderCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text=@"sf";
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    NSLog(@"server :%@",appDelagete.avServer);
//    DetailViewController *detail = [[ServerContentViewController alloc] initWithAvServer:appDelagete.avServer objectId:@"0"];

    
//    ServerContentViewController *detail=[[ServerContentViewController alloc]initWithAvServer:appDelagete.avServer objectId:@"0"];
//    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark -
#pragma mark - actions
- (IBAction)renderBtAction:(id)sender {
//    self.renderViewController = [[RenderViewController alloc] init];
//    
//    [self.navigationController pushViewController:self.renderViewController animated:YES];
//    [self presentViewController:self.renderViewController animated:YES completion:nil];
}

- (IBAction)serverBtAction:(id)sender {
    self.serverController=[[ServerViewController alloc]init];
    [self.navigationController pushViewController:self.serverController animated:YES];
//    [self presentViewController:self.serverController animated:YES completion:nil];
}

- (IBAction)settingAction:(id)sender {
    NSLog(@"设置");
    if(kIS_IPAD){
        SettingViewController *setting=[[SettingViewController alloc]init];
        UIPopoverController *popoverController=[[UIPopoverController alloc]initWithContentViewController:setting];
        popoverController.contentViewController.contentSizeForViewInPopover=CGSizeMake(300, 500);
        
        [popoverController presentPopoverFromRect:self.setupBt.frame inView:self.bottomView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    
}

- (IBAction)catalogBtAction:(id)sender {
    [self bringCatagoryViewToFront];
    
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    MediaServerBrowser *browser = [[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid delegate:self.itemsViewController];
    
    //catalogNav视图用于按照目录层级的方式进行访问server资源
    if(self.catalogNav){
        [self.catalogNav.navigationController popToRootViewControllerAnimated:YES];
        self.itemsViewController.browser=browser;
    }
    else{
        self.itemsViewController = [[ItemsViewController alloc] init];
        
        self.itemsViewController.browser = browser;
        //add catalog style nav 添加层级目录浏览界面
        self.catalogNav=[[UINavigationController alloc]initWithRootViewController:self.itemsViewController];
        self.catalogNav.view.frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height);
        
        [self.view addSubview:self.catalogNav.view];
    }
    
    
    
    
}

- (IBAction)listLookAction:(id)sender {
    NSLog(@"列表浏览");
}

- (IBAction)iconLookAction:(id)sender {
    NSLog(@"图标浏览");
}

- (IBAction)bySongAction:(id)sender {
    NSLog(@"按歌曲浏览");
    [self bringAllMusicViewToFront];
}

- (IBAction)byZuoquAction:(id)sender {
    NSLog(@"按作曲浏览");
    [self bringAllMusicViewToFront];
    
}

- (IBAction)byArtistAction:(id)sender {
    NSLog(@"按艺术家浏览");
    [self bringAllMusicViewToFront];
}

- (IBAction)byAlbumAction:(id)sender {
    NSLog(@"按专辑浏览");
    [self bringAllMusicViewToFront];
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
#pragma mark - notion controls
- (void)playWithAvItem:(NSNotification *)sender{
    
}
- (void)getServerAction:(NSNotification *)sender{
    NSDictionary *userinfo=[sender userInfo];
    NSString *serverUuid = [userinfo objectForKey:@"server"];
    
    if(self.allMusicController){
//        self.allMusicController.server=serverUuid;
        [self.view bringSubviewToFront:self.allMusicController.view];
    }
    else{
        self.allMusicController = [[AllMusicController alloc]init];
//        self.allMusicController.server = serverUuid;
        self.allMusicController.view.frame=CGRectMake(0, kContentBaseY+self.topView.frame.size.height, kContentViewWidth-self.rightView.frame.size.width, self.view.frame.size.height-self.topView.frame.size.height-self.bottomView.frame.size.height);
        [self.view addSubview:self.allMusicController.view];
    }
    
}
@end

