//
//  ItemsViewController.m
//  MediaBrowserTest
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "ServerContentController.h"
#import "AppDelegate.h"

@interface ServerContentController ()<MediaServerBrowserDelegate>

@property (nonatomic, strong) NSArray* itemArr;
@property (nonatomic)BOOL browserRoot;
@property (nonatomic,copy)NSString *browserObjID;
@end

@implementation ServerContentController

@synthesize browser = browser_;
@synthesize itemArr = itemArr_;
- (id)initWithFrame:(CGRect)frame root:(BOOL)rootOrNot objectId:(NSString*)anObjectId{
    self=[super init];
    if(self){
        self.tableView.frame=frame;
        //search
        NSLog(@"search");
        self.itemArr=[NSArray array];
        self.browserRoot=rootOrNot;
        self.browserObjID=anObjectId;
        
        AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
        MediaServerBrowser *bser = [[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid delegate:self];
        self.browser=bser;
        
        if(self.browserRoot){
            [self.browser browseRoot];
        }
        else{
            [self.browser browse:self.browserObjID];
        }

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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    MediaServerItem * item = [itemArr_ objectAtIndex:indexPath.row];
    //取得当前的server
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSString *serverUuid=appDelagete.serverUuid;
    
    if(item.type==FOLDER){
        NSLog(@"folder");
//        SubItemsViewController *controller = [[SubItemsViewController alloc] init];
        ServerContentController *controller=[[ServerContentController alloc]initWithFrame:self.view.bounds root:NO objectId:item.objID];
        MediaServerBrowser *browser = [[MediaServerBrowserService instance] browserWithUUID:serverUuid delegate:controller];
        controller.browser = browser;
//        controller.browseID=item.objID;
        
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
