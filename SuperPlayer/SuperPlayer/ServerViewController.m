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

@implementation ServerViewController

@synthesize detailViewController = _detailViewController;
@synthesize dataSource = dataSource_;
@synthesize avController = _avController;
@synthesize renderers = _renderers;



//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        self.title = NSLocalizedString(@"DLNA Server", @"Master");
//    }
//    return self;
//}

- (void)dealloc
{
//    [self.avController stop];
//    [_avController release];
//    [_detailViewController release];
//    self.avController = nil;
    [super dealloc];
}

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
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    //启动
    [[MediaServerBrowserService instance] startService:self];
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
//    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
//    appDelagete.avServer = (CGUpnpAvServer*)[self.dataSource objectAtIndex:indexPath.row];
//    [SVProgressHUD showSuccessWithStatus:@"已选择媒体服务器" maskType:SVProgressHUDMaskTypeBlack];
//    
//    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:(CGUpnpAvServer*)[self.dataSource objectAtIndex:indexPath.row],@"server", nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"kSelectServer" object:nil userInfo:userinfo];
    NSString *uuid = [[_dmsArr allKeys] objectAtIndex:indexPath.row];
    ItemsViewController *controller = [[ItemsViewController alloc] init];
    MediaServerBrowser *browser = [[MediaServerBrowserService instance] browserWithUUID:uuid delegate:controller];
    controller.browser = browser;
    
    //PlaybackViewController *playerViewContorller = [[PlaybackViewController alloc] initWithUrl:url];
//    [self presentViewController:controller animated:YES completion:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark MediaServerBrowserDelegate
//service delegate
- (BOOL)onMediaServerBrowserAdded:(NSString *)friendlyName uuid:(NSString *)uuid
{
    //NSLog(@"[ViewController] [onMediaServerBroserAdded] friendlyName = %@", friendlyName);
    [_dmsArr setObject:friendlyName forKey:uuid];
    [self.listTableView reloadData];
    return YES;
}

- (void)onMediaServerBrowserRemoved:(NSString *)friendlyName uuid:(NSString *)uuid
{
    //NSLog(@"[ViewController] [onMediaServerBroserRemoved] friendlyName = %@", friendlyName);
    [_dmsArr removeObjectForKey:friendlyName];
}
@end
