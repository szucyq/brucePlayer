//
//  RenderViewController.m
//  BPlayer
//
//  Created by Bruce on 15/6/28.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "FavoriteListController.h"
#import "AppDelegate.h"

#import <MediaServerBrowserService/MediaRenderControllerService.h>

@interface FavoriteListController ()

@end

@implementation FavoriteListController
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
    self.title=@"收藏列表";
    self.listArray=[NSMutableArray array];
    [self getAllMusicData];
    
}
- (void)getAllMusicData{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(!appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        [self.listArray removeAllObjects];
        return;
    }
    NSLog(@"server uuid :%@",appDelagete.serverUuid);
    
    NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"select * from favourite where server='",appDelagete.serverUuid,@"';"];
    //    NSString *sql=[NSString stringWithFormat:@"%@",@"select * from music;"];
    //查询数据
    [CoreFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            NSLog(@"%@-%@",[set stringForColumn:@"title"],[set stringForColumn:@"uri"]);
            //date
            NSString *dateStr=[set stringForColumn:@"date"];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
            dateFormatter.dateFormat= @"yyyy-MM-dd";
            NSDate *date=[dateFormatter dateFromString:dateStr];
            NSLog(@"date:%@",date);
            //duration
            NSString *durationStr=[set stringForColumn:@"duration"];
            NSTimeInterval duration=[durationStr floatValue];
            
            
            MediaServerItem *item=[[MediaServerItem alloc]init];
            item.title=[set stringForColumn:@"title"];
            item.uri=[set stringForColumn:@"uri"];
            item.composer=[set stringForColumn:@"composer"];
            item.date=date;
            item.album=[set stringForColumn:@"album"];
            //            item.contentFormat=[set stringForColumn:@"genres"];
            item.artist=[set stringForColumn:@"artist"];
            item.duration=duration;
            NSArray *gArray=[NSArray arrayWithObject:[set stringForColumn:@"genres"]];
            item.genres=gArray;
            
            [self.listArray addObject:item];
        }
        
    }];
    NSLog(@"items:%@",self.listArray);
    [self.listTableView reloadData];
}
//NSString *stringFromInterval(NSTimeInterval timeInterval)
//{
//#define SECONDS_PER_MINUTE (60)
//#define MINUTES_PER_HOUR (60)
//#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
//#define HOURS_PER_DAY (24)
//    
//    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
//    int ti = round(timeInterval);
//    
//    //    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
//    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
//    
//#undef SECONDS_PER_MINUTE
//#undef MINUTES_PER_HOUR
//#undef SECONDS_PER_HOUR
//#undef HOURS_PER_DAY
//}
//- (void)viewDidLayoutSubviews{
//    self.navigationController.navigationBarHidden=NO;
//}
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
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    
    
//    NSDictionary *renders = [MediaRenderControllerService instance].renderDic;
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
//    NSString *title=item.title;
    cell.textLabel.text = item.title;
    //cell.textLabel.text = [NSString stringWithFormat:@"%@%ld",@"render",(long)indexPath.row];
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
//        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:                                                                _lastIndexPath];
//        oldCell.accessoryType = UITableViewCellAccessoryNone;        _lastIndexPath = indexPath;
//    }
    //
    [self dismissViewControllerAnimated:YES completion:^{
        MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
        NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
    }];
    

    
}



@end
