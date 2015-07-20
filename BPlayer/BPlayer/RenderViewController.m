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
        self.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        
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
    NSString *uuid=[[self.renderDic allKeys] objectAtIndex:indexPath.row];
    NSDictionary *render=[self.renderDic objectForKey:uuid];
    cell.textLabel.text = [render valueForKey:@"FriendlyName"];
    //cell.textLabel.text = [NSString stringWithFormat:@"%@%ld",@"render",(long)indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger newRow = [indexPath row];
    NSInteger oldRow = [_lastIndexPath row];
    if (newRow != oldRow){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:                                                                indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:                                                                _lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;        _lastIndexPath = indexPath;
    }
    //保存render信息，供播放时使用
//    NSDictionary *renders = [MediaRenderControllerService instance].renderDic;
    NSString *renderUuid = [[self.renderDic allKeys] objectAtIndex:indexPath.row];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    appDelagete.renderUuid=renderUuid;
    NSLog(@"uuid 1:%@",renderUuid);
    //    appDelagete.avRenderer = (CGUpnpAvRenderer*)[self.dataSource objectAtIndex:indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:@"已选择播放器" maskType:SVProgressHUDMaskTypeBlack];
    [self dismissViewControllerAnimated:YES completion:nil];
//    NSString *friendlyName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//    NSDictionary *dic = [MediaRenderControllerService instance].renderDic;
//    NSString *UUID = nil;
//    for (NSString *key in dic.allKeys) {
//        NSString *tmp = [dic valueForKey:key];
//        if ( [tmp isEqualToString:friendlyName] ) {
//            UUID = key;
//        }
//    }
//    NSLog(@"uuid 2:%@",UUID);

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
