//
//  SettingController.m
//  BPlayer
//
//  Created by Bruce on 15/7/12.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "SettingController.h"

#define kSettingTvWidth 250

@interface SettingController ()

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if(self.listTableView){
        [self.listTableView removeFromSuperview];
    }
    self.listTableView=[[UITableView alloc]init];
    self.listTableView.delegate=self;
    self.listTableView.dataSource=self;
    self.listTableView.frame=CGRectMake(0, kContentBaseY, kSettingTvWidth, kContentViewHeight);
    [self.view addSubview:self.listTableView];
    [self.view bringSubviewToFront:self.listTableView];
    //
//    self.listArray=[NSMutableArray arrayWithObjects:@"图标浏览方式显示数量",@"自动锁屏",@"用户指南",@"用户反馈",@"版本", nil];
    self.listArray=[NSMutableArray arrayWithObjects:@"ES9018 DAC",@"WM8741 DAC",@"Analog Input",@"S/P DIF",@"DSD Output Mode",@"Default Setting",@"WIFI",@"About", nil];
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
    //    return self.listArray.count;
    return self.listArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.listArray objectAtIndex:indexPath.row];
    return cell;
}




#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row:%d",indexPath.row);
    if(indexPath.row==0){
        self.iconNumView.hidden=YES;
    }
    else{
        self.iconNumView.hidden=YES;
    }
}
#pragma mark -
#pragma mark 图标浏览
- (IBAction)iconNumAction:(id)sender {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSInteger tag=[(UIButton*)sender tag];
    if(tag==1){
        //3
        [defaults setObject:@"3" forKey:kIconNumber];
        [defaults setObject:@"130" forKey:kIconWidth];
        [defaults synchronize];
    }
    else if(tag==2){
        //4
        [defaults setObject:@"4" forKey:@"iconNum"];
        [defaults setObject:@"110" forKey:@"iconWidth"];
        [defaults synchronize];
    }
    else if(tag==3){
        //5
        [defaults setObject:@"5" forKey:@"iconNum"];
        [defaults setObject:@"90" forKey:@"iconWidth"];
        [defaults synchronize];
    }
    else if(tag==4){
        //6
        [defaults setObject:@"6" forKey:@"iconNum"];
        [defaults setObject:@"70" forKey:@"iconWidth"];
        [defaults synchronize];
    }
}
@end
