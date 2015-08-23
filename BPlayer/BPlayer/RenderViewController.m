//
//  RenderViewController.m
//  BPlayer
//
//  Created by Bruce on 15/6/28.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "RenderViewController.h"
#import "AppDelegate.h"

#import <MediaServerBrowserService/MediaRenderControllerService.h>

@interface RenderViewController ()

@end

@implementation RenderViewController
- (id)initWithFrame:(CGRect)frame{
    self=[super init];
    if(self){
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44.0)];
        label.text=@"设备";
        label.textAlignment=NSTextAlignmentCenter;
        [self.view addSubview:label];
        
        self.listTableView.frame=CGRectMake(0, 44, frame.size.width, frame.size.height);
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _lastIndexPath=[NSIndexPath indexPathForRow:-1 inSection:0];
    // Do any additional setup after loading the view.
    self.title=@"设备";
    self.renderDic=[NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaRenderAdded:)
                                                 name:@"MediaRenderAddedNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaRenderRemove:)
                                                 name:@"MediaRenderRemovedNotification"
                                               object:nil];
    
    //先停止
    //[[MediaRenderControllerService instance] stopService];
    //启动
    if ( ![MediaRenderControllerService instance].isRunning ) {
        NSLog(@"搜索render");
        [[MediaRenderControllerService instance] startService];
    }

    NSDictionary *selfRender=[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice]name],@"FriendlyName",@"self",@"UUID", nil];

    [self.renderDic setObject:selfRender forKey:@"self"];
    [self.listTableView reloadData];
    NSLog(@"renders:%@",self.renderDic);
    
}
- (void)viewDidLayoutSubviews{
    self.navigationController.navigationBarHidden=NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return [MediaRenderControllerService instance].renderDic.count;
    return self.renderDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
//    NSDictionary *renders = [MediaRenderControllerService instance].renderDic;
    NSString *key=[[self.renderDic allKeys] objectAtIndex:indexPath.row];
    NSDictionary *render=[self.renderDic objectForKey:key];
    cell.textLabel.text = [render valueForKey:@"FriendlyName"];

    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    NSLog(@"app key:%@---key:%@",appDelagete.renderUuid,key);
    if(appDelagete.renderUuid &&[appDelagete.renderUuid isEqualToString:key]){
        cell.textLabel.textColor=[UIColor blueColor];
    }
    else{
        cell.textLabel.textColor=[UIColor blackColor];
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSInteger newRow = [indexPath row];
//    NSInteger oldRow = [_lastIndexPath row];
//    if (newRow != oldRow){
//        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:                                                                indexPath];
//        newCell.textLabel.textColor=[UIColor blueColor];
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:                                                                _lastIndexPath];
//        oldCell.accessoryType = UITableViewCellAccessoryNone;        _lastIndexPath = indexPath;
//    }
    
    
    //保存render信息，供播放时使用
    NSString *renderUuid = [[self.renderDic allKeys] objectAtIndex:indexPath.row];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    appDelagete.renderUuid=renderUuid;
    NSLog(@"uuid 1:%@",renderUuid);
    [self.listTableView reloadData];
    
    //通知
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:renderUuid,@"render", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kSelectRender" object:nil userInfo:userinfo];
    

    [SVProgressHUD showSuccessWithStatus:@"已选择设备"];
    [self dismissViewControllerAnimated:YES completion:nil];


}

- (void)mediaRenderAdded:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSLog(@"renders:%@",[MediaRenderControllerService instance].renderDic);
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.renderDic setObject:msg forKey:uuid];
    [self.listTableView reloadData];
}

- (void)mediaRenderRemove:(NSNotification*)notification
{
    NSDictionary *msg = notification.object;
    //NSString *friendlyName = [msg valueForKey:@"FriendlyName"];
    NSString *uuid = [msg valueForKey:@"UUID"];
    [self.renderDic removeObjectForKey:uuid];
    [self.listTableView reloadData];
}

@end
