        //
//  MasterViewController.m
//  DLNASample
//
//  Created by 健司 古山 on 12/05/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServerViewController.h"
//#import "DetailViewController.h"
#import "AppDelegate.h"


//#import "RendererTableViewController.h"

//#include <cybergarage/upnp/cupnp.h>
//#include <cybergarage/xml/cxml.h>

@interface ServerViewController()
@property (nonatomic, strong) ServerContentViewController* contentController;

@end
@implementation ServerViewController


@synthesize dataSource = dataSource_;
@synthesize renderers = _renderers;

@synthesize contentController = contentController_;




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _lastIndexPath=[NSIndexPath indexPathForRow:-1 inSection:0];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.dmsArr=[NSMutableDictionary dictionary];
    self.title=@"选择服务器";
//    [self setCustomRightButtonText:@"预加载资源" withImgName:nil];
//    [self setCustomBackButtonText:@"返回" withImgName:nil];

    UIBarButtonItem *rightBt=[[UIBarButtonItem alloc]initWithTitle:@"预加载资源" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    self.navigationItem.rightBarButtonItem = rightBt;
    //先停止
    //[[MediaServerBrowserService instance] stopService];
    //启动
    [[MediaServerBrowserService instance] startService];
    
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
        /*
        MediaServerBrowser *browser=[[MediaServerBrowserService instance] findBrowser:appDelagete.serverUuid];
        if(browser){
            NSLog(@"browser:%@",browser);
           [[MediaServerBrowserService instance]destroyBrowser:browser];
        }
        */
        //
        /*
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithUUID:appDelagete.serverUuid delegate:self];
        [crawler crawl];
         */
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
}
- (void)viewDidLayoutSubviews{
    self.navigationController.navigationBarHidden=NO;
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
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // ip地址，名字，图标
    //
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[_dmsArr
                            allValues] objectAtIndex:indexPath.row];
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
    NSString *uuid = [[_dmsArr allKeys] objectAtIndex:indexPath.row];
    appDelagete.serverUuid=uuid;

    [SVProgressHUD showSuccessWithStatus:@"已选择媒体服务器" maskType:SVProgressHUDMaskTypeBlack];
    
    //此处选择server后，传递server信息，让前端刷新对应server内容
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:uuid,@"server", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kSelectServer" object:nil userInfo:userinfo];
    return;
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

#pragma mark -
#pragma mark MediaServerBrowserDelegate
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
