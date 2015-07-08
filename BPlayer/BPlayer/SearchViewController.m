//
//  NOXiaoquController.m
//  uulife
//
//  Created by Bruce on 15-5-20.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "SearchViewController.h"
#import "CoreFMDB.h"


@interface SearchViewController ()
@property (nonatomic,retain)UISearchBar *musicSearchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"请输入搜索的内容";
    //add search bar
    self.musicSearchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, kContentBaseY, kContentViewWidth, 50)];
    
    _musicSearchBar.delegate=self;
    _musicSearchBar.placeholder=@"请输入歌曲名字";
    
    [self.view addSubview:self.musicSearchBar];
    
    
    //add table view
    self.listTableView.frame=CGRectMake(0, kContentBaseY+55, kContentViewWidth, kContentViewHeightNoTab-55);
    
}
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO];
//}
- (void)viewDidLayoutSubviews{
    self.navigationController.navigationBarHidden=NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma UISearch bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self musicKeyword:searchBar.text];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self musicKeyword:searchBar.text];
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark 搜索歌曲
- (void)musicKeyword:(NSString*)sender{
    NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"select * from music where title like '%",sender,@"%';"];
    [CoreFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            NSLog(@"%@-%@",[set stringForColumn:@"title"],[set stringForColumn:@"uri"]);
            MediaServerItem *item=[[MediaServerItem alloc]init];
            item.title=[set stringForColumn:@"title"];
            item.uri=[set stringForColumn:@"uri"];
            [self.listArray addObject:item];
        }
        
    }];
    
   [self.listTableView reloadData];
}
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    //    static NSString *CellIdentifier = @"Cell";
    //
    //    PhoneListCell *cell=(PhoneListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //
    //    if(cell==nil){
    //        NSArray *array=[[NSBundle mainBundle]loadNibNamed:@"PhoneListCell" owner:self options:nil];
    //        cell=[array objectAtIndex:0];
    //
    //    }
    // Configure the cell...
    
    
    
//    NSString *name=[[self.listArray objectAtIndex:indexPath.row] valueForKey:@"CommunityName"];
//    
//    NSString *ProvinceName=[[self.listArray objectAtIndex:indexPath.row] valueForKey:@"ProvinceName"];
//    NSString *CityName=[[self.listArray objectAtIndex:indexPath.row] valueForKey:@"CityName"];
//    NSString *CountyName=[[self.listArray objectAtIndex:indexPath.row] valueForKey:@"CountyName"];
//    
//    NSString *subName=[NSString stringWithFormat:@"%@%@%@",ProvinceName,CityName,CountyName];
    
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    
    cell.detailTextLabel.text=item.uri;
    
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 44.0;
//}
#pragma mark -
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
}

@end
