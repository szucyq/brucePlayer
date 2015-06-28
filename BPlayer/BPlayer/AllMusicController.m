//
//  AllMusicController.m
//  SuperPlayer
//
//  Created by Bruce on 15/6/26.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "AllMusicController.h"

@interface AllMusicController ()

@end

@implementation AllMusicController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.listTableView.frame=self.view.bounds;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)setByType:(NSString *)byType{
    NSLog(@"set byType:%@",byType);
    if([byType isEqualToString:@"music"]){
        self.listArray=[NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    }
    else{
        self.listArray=[NSMutableArray arrayWithObjects:@"11",@"22",@"33", nil];
    }
    [self.listTableView reloadData];
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
    // Navigation logic may go here, for example:
    
    //如果是音频文件播放，则要在主界面控制
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:@"音频",@"item", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
}

@end
