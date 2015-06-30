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
@property (nonatomic)CGRect selfFrame;
@end

@implementation ServerContentController

@synthesize browser = browser_;
@synthesize itemArr = itemArr_;



- (id)initWithFrame:(CGRect)frame root:(BOOL)rootOrNot objectId:(NSString*)anObjectId
{
    self=[super init];
    if(self){
//        self.tableView.frame=frame;

        self.itemArr=[NSArray array];
        self.browserRoot=rootOrNot;
        self.browserObjID=anObjectId;
        self.selfFrame=frame;
        self.title=anObjectId;
        
        AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
        self.browser = [[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid delegate:self];

        
        

    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    self.tableView.frame=self.selfFrame;
    NSLog(@"browser is :%@",self.browser);
    if(self.browserRoot){
        NSLog(@"broser root");
        [self.browser browseRoot];
    }
    else{
        NSLog(@"broser objid:%@",self.browseID);
        [self.browser browse:self.browserObjID];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    NSLog(@"item arr:%@",itemArr_);
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
//    NSLog(@"items 2:%@",items);
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

    if(item.type==FOLDER){
        NSLog(@"folder:%@",self.navigationController.viewControllers);
        NSLog(@"item objid:%@",item.objID);
        ServerContentController *sContentController=[[ServerContentController alloc]initWithFrame:self.tableView.bounds root:NO objectId:item.objID];
        NSLog(@"view:%@",sContentController);
        
        TestTableViewController *test=[[TestTableViewController alloc]init];
        
        [self.navigationController pushViewController:test animated:YES];

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



@end
