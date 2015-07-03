//
//  ServerContentViewController.m
//  BPlayer
//
//  Created by Bruce on 15/6/30.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "ServerContentViewController.h"
#import "AppDelegate.h"

@interface ServerContentViewController ()
@property (nonatomic, strong) NSArray* itemArr;
@property (nonatomic)BOOL browserRoot;
@property (nonatomic) NSMutableArray *objIDArr;
@property (nonatomic)CGRect selfFrame;

@end

@implementation ServerContentViewController
- (id)initWithFrame:(CGRect)frame
{
    self=[super init];
    if(self){
        self.selfFrame = frame;
        //AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
        //self.browser = [[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objIDArr = [[NSMutableArray alloc] init];
    //self.itemArr = @[];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.frame=self.selfFrame;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.itemArr = nil;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
//    self.title = @"root";
    self.itemArr=[NSArray array];
    self.browserRoot = YES;
    [self.objIDArr removeAllObjects];
    //[self.objIDArr addObject:@"0"];

    //[self.browser browseRoot];
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
    if (self.browserRoot) {
        return self.itemArr.count;
    }
    else{
        if(self.itemArr.count==0)
            return 0;
    }
    return self.itemArr.count + 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if ( !self.browserRoot ) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"..";
        } else {
            MediaServerItem *item = [self.itemArr objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = item.title;
        }
    } else {
        MediaServerItem *item = [self.itemArr objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
    }
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaServerItem * item;
    //go back
    if ( !self.browserRoot
        && indexPath.row == 0) {

        [self.objIDArr removeLastObject];
        NSString *parentObjID = [self.objIDArr lastObject];
        //[self.browser browse:parentObjID];
        return;
    }
    // Navigation logic may go here, for example:
    
    else if(self.browserRoot){
        item = [self.itemArr objectAtIndex:indexPath.row];
    }
    else{
        item = [self.itemArr objectAtIndex:indexPath.row-1];
    }
    //根据类型判断处理
    if(item.type==FOLDER){
        
        NSLog(@"folder:%@",self.navigationController.viewControllers);
        NSLog(@"item objid:%@",item.objID);
        
        //[self.browser browse:item.objID];
        //ServerContentViewController *sContentController=[[ServerContentViewController alloc]initWithFrame:self.tableView.bounds root:NO objectId:item.objID];
        //NSLog(@"view:%@",sContentController);
        
//        TestTableViewController *test=[[TestTableViewController alloc]init];
        
        //[self.navigationController pushViewController:sContentController animated:YES];
//        [self presentViewController:sContentController animated:YES completion:nil];
        
    }
    else if(item.type==AUDIO){
        //如果是音频文件播放，则要在主界面控制
        NSLog(@"audio :%@",item);
        NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
    }
    else{
        NSLog(@"暂不支持播放:%d",item.type);
    }
}
#pragma mark Browser delegate
/*
- (void)onBrowseResult:(int)res
                  path:(NSString*)path
                 items:(NSArray*)items
{
    if (res == 0) {
        self.browserRoot = [path isEqualToString:@"0"];
        NSString *currentObjID = [self.objIDArr lastObject];
        if ( ![currentObjID isEqualToString:path] ) {
            [self.objIDArr addObject:path];
            NSLog(@"objid arr:%@",self.objIDArr);
        }
        
        self.itemArr = items;
        NSLog(@"items:%@",self.itemArr);
        [self.tableView reloadData];
    }
    //    NSLog(@"items 2:%@",items);
}*/
@end