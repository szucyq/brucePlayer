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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"选择播放器";
    
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
    [[MediaRenderControllerService instance] startService];
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
    return [MediaRenderControllerService instance].renderDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSDictionary *renders = [MediaRenderControllerService instance].renderDic;
    NSString *UUID = [[renders allKeys] objectAtIndex:indexPath.row];
    cell.textLabel.text = [renders valueForKey:UUID];
    //cell.textLabel.text = [NSString stringWithFormat:@"%@%ld",@"render",(long)indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //保存render信息，供播放时使用
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    //    appDelagete.avRenderer = (CGUpnpAvRenderer*)[self.dataSource objectAtIndex:indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showSuccessWithStatus:@"已选择播放器" maskType:SVProgressHUDMaskTypeBlack];
}


- (void)mediaRenderAdded:(NSNotification*)notification
{
    [self.listTableView reloadData];
}

- (void)mediaRenderRemove:(NSNotification*)notification
{
    [self.listTableView reloadData];
}

@end
