//
//  ItemsViewController.m
//  MediaBrowserTest
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "SubItemsViewController.h"
#import "AppDelegate.h"

@interface SubItemsViewController ()<MediaServerBrowserDelegate>

@property (nonatomic, strong) NSArray* itemArr;

@end

@implementation SubItemsViewController

@synthesize browser = browser_;
@synthesize itemArr = itemArr_;
- (id)initWithFrame:(CGRect)frame{
    self=[super init];
    if(self){
        self.tableView.frame=frame;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title=@"目录浏览";
    //search
    NSLog(@"search browser id:%@",self.browseID);
    self.itemArr=[NSArray array];
    [browser_ browse:self.browseID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return itemArr_.count;
}

- (void)onBrowseResult:(int)res
                  path:(NSString*)path
                 items:(NSArray*)items
{
    if (res == 0) {
        itemArr_ = items;
        NSLog(@"items:%@",itemArr_);
        [self.tableView reloadData];
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
    }
    NSLog(@"items 2:%@",items);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    MediaServerItem * item = [itemArr_ objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    MediaServerItem * item = [itemArr_ objectAtIndex:indexPath.row];
    //取得当前的server
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *serverUuid=appDelagete.serverUuid;
    
    if(item.type==FOLDER){
        
        SubItemsViewController *controller = [[SubItemsViewController alloc] init];
        MediaServerBrowser *browser = [[MediaServerBrowserService instance] browserWithUUID:serverUuid delegate:controller];
        controller.browser = browser;
        controller.browseID=item.objID;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(item.type==AUDIO){
        //如果是音频文件播放，则要在主界面控制
        NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:@"音频",@"item", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
    }
    else{
        NSLog(@"暂不支持播放:%d",item.type);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
