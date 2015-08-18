        //
//  MasterViewController.m
//  DLNASample
//
//  Created by 健司 古山 on 12/05/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServerViewController.h"
#import "AppDelegate.h"

static BOOL displaySetting=NO;

@interface ServerViewController()
@property (nonatomic, strong) ServerContentViewController* contentController;
@property (nonatomic)CGRect viewFrame;
@end
@implementation ServerViewController


@synthesize dataSource = dataSource_;
@synthesize renderers = _renderers;

@synthesize contentController = contentController_;

- (id)initWithDevices:(NSMutableDictionary *)sender frame:(CGRect)frame{
    self=[super init];
    if(self){
        self.dmsArr=sender;
        self.viewFrame=frame;
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (void)setVisible:(BOOL)visible {
    self.view.hidden = !visible;
}
#pragma mark - View lifecycle
- (void)viewDidLayoutSubviews{
    self.navigationController.navigationBarHidden=NO;
    
//    self.view.frame=CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height);
    if(self.listTableView){
        [self.listTableView removeFromSuperview];
    }
    self.listTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height-100) style:UITableViewStyleGrouped];
    self.listTableView.delegate=self;
    self.listTableView.dataSource=self;

    
    [self.view addSubview:self.listTableView];
    [self.view bringSubviewToFront:self.listTableView];
    [self.listTableView reloadData];
    
    NSLog(@"self view frame 1:%@",[NSValue valueWithCGRect:self.view.frame]);
    //设置按钮
    UIView *view=[self.view viewWithTag:1001];
    if(!view){
        UIButton *settingBt=[UIButton buttonWithType:UIButtonTypeCustom];
        [settingBt setFrame:CGRectMake((kLeftViewWidth-56)/2.0,self.listTableView.frame.origin.y+self.listTableView.frame.size.height , 56, 56)];
        [settingBt addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        [settingBt setBackgroundImage:[UIImage imageNamed:@"setting_unselected.png"] forState:UIControlStateNormal];
        settingBt.tag=1001;
        [self.view addSubview:settingBt];
        [self.view bringSubviewToFront:settingBt];
    }
    
    
}
- (void)viewDidLoad
{
    
    NSLog(@"self view frame 2:%@",[NSValue valueWithCGRect:self.view.frame]);
   
    _lastIndexPath=[NSIndexPath indexPathForRow:-1 inSection:0];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.dmsArr=[NSMutableDictionary dictionary];
    self.listArray=[NSMutableArray array];
    self.title=@"选择服务器";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServerAdded:)
                                                 name:@"MediaServerAddedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServerRemove:)
                                                 name:@"MediaServerRemovedNotification"
                                               object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLeftView:) name:@"LeftRefresh" object:nil];
    
    
}
- (void)reloadLeftView:(NSNotification*)sender{
    NSDictionary *dic=[sender userInfo];
    self.dmsArr=[dic objectForKey:@"server"];
    NSLog(@"servers:%@",self.dmsArr);
    [self.listTableView reloadData];
}
- (void)settingAction{
    NSLog(@"setting action");
    displaySetting=!displaySetting;
    NSString *display;
    if(displaySetting){
        display=@"1";
    }
    else{
        display=@"0";
    }
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:display,@"setting", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"setting" object:nil userInfo:userinfo];
}
- (void)rightButtonAction{
    [self performSelector:@selector(rightToAction:) withObject:nil];
}
- (void)backToAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightToAction:(id)sender{
    NSLog(@"实现自己navigation bar 右侧按钮的方法，如果没有实现会出现该提示");
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        
        MediaServerBrowser *browser=[[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid];
        
        
        //
        
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithBrowser:browser];
        [crawler crawl:^(BOOL ret, NSArray *items) {
            NSLog(@"crawler items = %@", items);
        }];
         
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
//- (void)leftButtonDidPush
//{
//    RendererTableViewController* viewController = [[RendererTableViewController alloc] initWithAvController:self.avController];
//    
//    [self.navigationController pushViewController:viewController animated:YES];
//    [viewController release];
//    
//}
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"dms arr:%@",_dmsArr);
    return [_dmsArr count];
//    return self.listArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // ip地址，名字，图标
    //
    static NSString *identifier=@"serverCell";
    ServerCell *cell=(ServerCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        NSArray *array=[[NSBundle mainBundle]loadNibNamed:@"ServerCell" owner:self options:nil];
        cell=[array objectAtIndex:0];
        
    }
    
    
    
    NSString *key=[[_dmsArr allKeys] objectAtIndex:indexPath.row];
    NSLog(@"this server:%@",[_dmsArr objectForKey:key]);
    cell.friendlyNameLabel.text=[[_dmsArr objectForKey:key] valueForKey:@"FriendlyName"];
    cell.ipLabel.text=[[_dmsArr objectForKey:key] valueForKey:@"IP"];
    
    NSString *iconUrl=[[_dmsArr objectForKey:key] valueForKey:@"iconUrl"];
    NSLog(@"server icon:%@",iconUrl);
    if([iconUrl isEqual:[NSNull null]] || iconUrl==nil){
        cell.iconIv.image=[UIImage imageNamed:@"Icon.png"];
        
    }
    else{
        ImageView *iv=[[ImageView alloc]initWithFrame:cell.iconIv.frame imageURLStr:iconUrl plactHolderImgName:@"icon.png" scale:NO];
        
        [cell.contentView addSubview:iv];
    }
    

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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = [_lastIndexPath row];
    if (newRow != oldRow){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:                                                                indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:                                                                _lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;        _lastIndexPath = indexPath;
    }
    
    
    //只是选择server，并不进入浏览。
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *key = [[_dmsArr allKeys] objectAtIndex:indexPath.row];
    NSString *uuid=[[_dmsArr objectForKey:key] valueForKey:@"UUID"];
    appDelagete.serverUuid=uuid;

//    [SVProgressHUD showSuccessWithStatus:@"已选择媒体服务器" maskType:SVProgressHUDMaskTypeBlack];
    
    //此处选择server后，传递server信息，让前端刷新对应server内容
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:uuid,@"server", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kSelectServer" object:nil userInfo:userinfo];
    
    //保存server
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setValue:uuid forKey:kDefaultServer];
    [defaults synchronize]
    ;
    
//    return;
    //暂时跳转下级目录测试
//    if (contentController_ == nil) {
//        contentController_ = [[ServerContentViewController alloc]initWithFrame:self.view.bounds];
//    }
//    contentController_.title=@"root";
//    NSLog(@"view:%@", contentController_);
//    contentController_.browser = [[MediaServerBrowserService instance] browserWithUUID:uuid delegate:contentController_];
//
//    [self.navigationController pushViewController:contentController_ animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.viewFrame.size.width, 44.0)];
    view.backgroundColor=[UIColor blueColor];
    
    UILabel *label=[[UILabel alloc]initWithFrame:view.frame];
    label.text=@"Local Sources";
    label.font=[UIFont systemFontOfSize:15.0];
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentLeft;
    [view addSubview:label];
    
    return view;
}
#pragma mark -
#pragma mark MediaServerBrowserDelegate

- (void)mediaServerAdded:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
//    NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
//    NSString *ip=[msg valueForKey:@"IP"];
//    NSString *iconUrl=[msg valueForKey:@"iconUrl"];
    [_dmsArr setObject:msg forKey:uuid];
//    _dmsArr=[NSMutableDictionary dictionaryWithDictionary:[[MediaServerBrowserService instance] mediaServers]];
    
    
//    [self.listArray addObject:msg];
    [self.listTableView reloadData];
}

- (void)mediaServerRemove:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [_dmsArr removeObjectForKey:uuid];
    [self.listTableView reloadData];
}
/*
//service delegate
- (BOOL)onMediaServerBrowserAdded:(NSString *)friendlyName uuid:(NSString *)uuid
{
    //NSLog(@"[ViewController] [onMediaServerBroserAdded] friendlyName = %@", friendlyName);
    NSLog(@"add uuid:%@",uuid);
    [_dmsArr setObject:friendlyName forKey:uuid];
    [self.listTableView reloadData];
    return YES;
}

- (void)onMediaServerBrowserRemoved:(NSString *)friendlyName uuid:(NSString *)uuid
{
    //NSLog(@"[ViewController] [onMediaServerBroserRemoved] friendlyName = %@", friendlyName);
     NSLog(@"remove uuid:%@",uuid);
    [_dmsArr removeObjectForKey:friendlyName];
}
 */
/*
#pragma mark Media server content crawler delegate
- (void)onCrawlResult:(NSArray *)items{
    NSLog(@"craw items:%@",items);
}
*/
@end
