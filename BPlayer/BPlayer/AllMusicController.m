//
//  AllMusicController.m
//  SuperPlayer
//
//  Created by Bruce on 15/6/26.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "AllMusicController.h"
#import "AppDelegate.h"
@interface AllMusicController ()

@end

@implementation AllMusicController
- (id)initWithFrame:(CGRect)frame{
    self=[super init];
    if(self){
        self.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor redColor];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        MediaServerBrowser *browser=[[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid];
        
        //
        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithBrowser:browser];
        [crawler crawl:^(BOOL ret, NSArray *items) {
            NSLog(@"crawler items = %@", items);
            self.listArray=items;
            [self.listTableView reloadData];
        }];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
        return;
    }
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
- (void)setServerUuid:(NSString *)serverUuid{
    
}
- (void)setByType:(NSString *)byType{
    NSLog(@"set byType:%@",byType);
    if([byType isEqualToString:@"music"]){
//        self.listArray=[NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    }
    else{
//        self.listArray=[NSMutableArray arrayWithObjects:@"11",@"22",@"33", nil];
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
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    return cell;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    //如果是音频文件播放，则要在主界面控制
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
}

@end
