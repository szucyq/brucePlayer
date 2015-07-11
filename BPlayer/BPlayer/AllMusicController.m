//
//  AllMusicController.m
//  SuperPlayer
//
//  Created by Bruce on 15/6/26.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//
//#define kMusicViewWidth 900
//#define kMusicViewHeight 600
#define kMusicTableRowHeigth 60

#import "AllMusicController.h"
#import "AppDelegate.h"
#import "CoreFMDB.h"
@interface AllMusicController (){
    BOOL  isicon;
    BOOL  islistIcon;
    BOOL  islist;
    UIView *scrollerview;
    float kMusicViewWidth;
    float kMusicViewHeight;
    
}


@end

@implementation AllMusicController
- (id)initWithFrame:(CGRect)frame{
    self=[super init];
    if(self){
        self.listTableView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        kMusicViewWidth=frame.size.width;
        kMusicViewHeight=frame.size.height;
        isicon=NO;
        islistIcon=YES;
        islist=NO;
        self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.view addSubview:self.scrollView];
        self.scrollView.backgroundColor=[UIColor blueColor];
        self.scrollView.hidden=YES;
        NSLog(@"sv:%@",self.scrollView);
        [self addscroller];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    self.view.backgroundColor=[UIColor redColor];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    if(appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
//        MediaServerBrowser *browser=[[MediaServerBrowserService instance] browserWithUUID:appDelagete.serverUuid];
        
        //
//        MediaServerCrawler *crawler=[[MediaServerCrawler alloc]initWithBrowser:browser];
//        [crawler crawl:^(BOOL ret, NSArray *items) {
//            NSLog(@"crawler items = %@", items);
//            self.listArray=items;
//            [self.listTableView reloadData];
//        }];
        
    }
    else{
//        [SVProgressHUD showErrorWithStatus:@"请先选择服务器" maskType:SVProgressHUDMaskTypeGradient];
//        return;
    }
    //查询数据
    [CoreFMDB executeQuery:@"select * from music;" queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            NSLog(@"%@-%@",[set stringForColumn:@"title"],[set stringForColumn:@"uri"]);
            MediaServerItem *item=[[MediaServerItem alloc]init];
            item.title=[set stringForColumn:@"title"];
            item.uri=[set stringForColumn:@"uri"];
            [self.listArray addObject:item];
        }
        
    }];
}
-(void)addscroller{
    int imageWidth=100;
    int imagecount=6;
    //    int imageWidth;
    //
    //    int imagecount;
    //    if (scrollerscale>=900) {
    //        imageWidth=140;
    //        imagecount=5;
    //    }else if (scrollerscale>=600&&scrollerscale<900){
    //        imageWidth=120;
    //
    //        imagecount=4;
    //
    //    }else if (scrollerscale>=300&&scrollerscale<600){
    //        imageWidth=100;
    //        imagecount=6;
    //
    //
    //    }else{
    //
    //        imageWidth=80;
    //        imagecount=7;
    //
    //    }
    
    
    for (UIView *subView in self.scrollView.subviews)
    {
        [subView removeFromSuperview];
    }
    if (scrollerview.superview) {
        [scrollerview removeFromSuperview];
    }
    
    scrollerview=[[UIView alloc]init];
    scrollerview.backgroundColor=[UIColor clearColor];
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    [scrollerview addGestureRecognizer:pinchGestureRecognizer];
    [self.scrollView addSubview:scrollerview];
    
    
    
    
    
    float paddingX=(kMusicViewWidth-imagecount*imageWidth)/(imagecount+1);
    float paddingY=paddingX+40;
    
    for (int i=0; i<self.listArray.count; i++) {
        NSDictionary *record=[self.listArray objectAtIndex:i];
        
        float x=i%imagecount*(imageWidth)+(i%imagecount+1)*paddingX;
        float y=i/imagecount*(imageWidth)+(i/imagecount+1)*paddingY;
        UIImageView *iconimage=[[UIImageView alloc]initWithFrame:CGRectMake(x, y, imageWidth, imageWidth)];
        NSString *stringimage=[NSString stringWithFormat:@"%@",[record objectForKey:@"albumimage"]];
        if ([stringimage isEqualToString:@"(null)"]) {
            [iconimage setImage:[UIImage imageNamed:@"temp"]];
        }else{
            [iconimage setImage:[record objectForKey:@"albumimage"]];
        }
        [self.scrollView addSubview:iconimage];
        
        
        UIButton * imagebutton=[[UIButton alloc]initWithFrame:CGRectMake(x, y, imageWidth, imageWidth)];
        imagebutton.tag=i+1000;
        [imagebutton addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imagebutton];
        
        UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(x, y+imageWidth, imageWidth, 20)];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.textAlignment = NSTextAlignmentCenter;
        titleText.font            = [UIFont systemFontOfSize:14.0];
        if([record objectForKey:@"title"]){
            [titleText setText:[record objectForKey:@"title"]];
        }
        else{
            [titleText setText:[NSString stringWithFormat:@"%@%d",@"music:",i+1]];
        }
        
        [self.scrollView addSubview:titleText];
        
        UILabel *detailText = [[UILabel alloc] initWithFrame: CGRectMake(x, y+imageWidth+20, imageWidth, 20)];
        detailText.backgroundColor = [UIColor clearColor];
        detailText.textAlignment = NSTextAlignmentCenter;
        detailText.font            = [UIFont systemFontOfSize:12.0];
        [detailText setText:@"album"];
        [self.scrollView addSubview:detailText];
        
        
    }
    float sizeHeight=(self.listArray.count/imagecount+1)*(imageWidth+paddingY);
    self.scrollView.contentSize=CGSizeMake(kMusicViewWidth, sizeHeight);
    //    self.scrollView.frame=scrollerview.frame;
    
    //    [scrollerview setFrame:CGRectMake(0, 0, kMusicViewWidth, kMusicViewHeight)];
    
    self.scrollView.backgroundColor=[UIColor clearColor];
    scrollerview.backgroundColor=[UIColor redColor];
    
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
-(void)tapAction:(UIButton*)sender{
    
    NSLog(@"tap icon:%ld",[sender tag]);
}
- (void)setByType:(NSString *)byType{
    [self.listArray removeAllObjects];
    NSLog(@"set byType-------:%@",byType);
    if([byType isEqualToString:@"music"]){
        [self songpress];
    }
    else if([byType isEqualToString:@"album"]){
        [self albumpress];
    }
    
    else if([byType isEqualToString:@"artist"]){
        [self artistpress];
    }
    else if([byType isEqualToString:@"zuoqu"]){
        [self composerpress];
    }
    else if([byType isEqualToString:@"date"]){
        [self datepress];
    }
    else if([byType isEqualToString:@"list"]){
        [self showlistIconAction];
    }
    else if([byType isEqualToString:@"icon"]){
        [self showiconAction];
    }
    else if([byType isEqualToString:@"list_icon"]){
        [self showlistIconAction];
    }
    else{
        [self songpress];
    }
    [self.listTableView reloadData];
    
}
- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    NSLog(@"handle pinch");
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    
//    recognizer.scale = 1;
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
//        
//        
//        
//    }
//    NSString *savestr=[NSString stringWithFormat:@"%f",scrollerview.frame.size.width];
//    NSLog(@"savestr is %@",savestr);
//    
//    float scrollerscale=[[[NSUserDefaults standardUserDefaults]objectForKey:@"recognizerwidth"] floatValue];
//    NSLog(@"scrollerscale is %f",scrollerscale);
//    
//    if (fabs([savestr floatValue]-scrollerscale)>100) {
//        [[NSUserDefaults standardUserDefaults] setObject:savestr forKey:@"recognizerwidth"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self addscroller];
//        
//    }
    
}
#pragma mark - 几种浏览方式
- (void)showiconAction{
    NSLog(@"showiconAction");
    [self.view bringSubviewToFront:self.scrollView];
    isicon=YES;
    islistIcon=NO;
    islist=NO;
    
    self.listTableView.hidden=YES;
    self.scrollView.hidden=NO;
}

- (void)showlistIconAction{
    NSLog(@"showlistIconAction");
    islistIcon=YES;
    isicon=NO;
    islist=NO;
    self.listTableView.hidden=NO;
    self.scrollView.hidden=YES;
    
}
- (void)showlistAction{
    NSLog(@"showlistAction");
    islistIcon=YES;
    isicon=NO;
    islist=NO;
    self.listTableView.hidden=NO;
    self.scrollView.hidden=YES;
    
}
- (void)songpress{
//    currentIndex=4;
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
    NSArray *temparray=[self.listArray sortedArrayUsingDescriptors:@[firstNameSortDescriptor]];
    [self.listArray removeAllObjects];
    self.listArray=[temparray mutableCopy];
    if (islistIcon==YES) {
        [self.listTableView reloadData];
    }else{
        
        for (UIView *subView in self.scrollView.subviews)
            
        {
            
            [subView removeFromSuperview];
            
        }
        [self addscroller];
        
    }
    NSLog(@"11111111111");
    
}
- (void)albumpress{
    //    currentIndex=2;
    
    NSLog(@"2222222");
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"album"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
    NSArray *temparray=[self.listArray sortedArrayUsingDescriptors:@[firstNameSortDescriptor]];
    [self.listArray removeAllObjects];
    self.listArray=[temparray mutableCopy];
    if (islistIcon==YES) {
        [self.listTableView reloadData];
    }else{
        
        for (UIView *subView in self.scrollView.subviews)
            
        {
            
            [subView removeFromSuperview];
            
        }
        [self addscroller];
        
    }
    
}
- (void)artistpress{
//    currentIndex=2;
    
    NSLog(@"333333333");
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"artist"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
    NSArray *temparray=[self.listArray sortedArrayUsingDescriptors:@[firstNameSortDescriptor]];
    [self.listArray removeAllObjects];
    self.listArray=[temparray mutableCopy];
    if (islistIcon==YES) {
        [self.listTableView reloadData];
    }else{
        
        for (UIView *subView in self.scrollView.subviews)
            
        {
            
            [subView removeFromSuperview];
            
        }
        [self addscroller];
        
    }
    
}
- (void)composerpress{
//    currentIndex=3;
    
    NSLog(@"4444444");
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"artist"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
    NSArray *temparray=[self.listArray sortedArrayUsingDescriptors:@[firstNameSortDescriptor]];
    [self.listArray removeAllObjects];
    self.listArray=[temparray mutableCopy];
    if (islistIcon==YES) {
        [self.listTableView reloadData];
    }else{
        
        for (UIView *subView in self.scrollView.subviews)
            
        {
            
            [subView removeFromSuperview];
            
        }
        [self addscroller];
        
    }
}
- (void)datepress{
    //    currentIndex=2;
    
    NSLog(@"55555555");
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"artist"
                                                                              ascending:YES
                                                                               selector:@selector(localizedStandardCompare:)];
    NSArray *temparray=[self.listArray sortedArrayUsingDescriptors:@[firstNameSortDescriptor]];
    [self.listArray removeAllObjects];
    self.listArray=[temparray mutableCopy];
    if (islistIcon==YES) {
        [self.listTableView reloadData];
    }else{
        
        for (UIView *subView in self.scrollView.subviews)
            
        {
            
            [subView removeFromSuperview];
            
        }
        [self addscroller];
        
    }
    
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMusicTableRowHeigth;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"serverCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
//    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = item.title;
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMusicViewWidth, kMusicTableRowHeigth)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [cell addSubview:bgView];
    
//    NSDictionary *record=[self.listArray objectAtIndex:indexPath.row];
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 120, 30)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.title ) {
        [titleLabel setText:@"unknow"];
    }else{
        [titleLabel setText:item.title];
    }
    [bgView addSubview:titleLabel];
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 30)];
    timeLabel.font = [UIFont systemFontOfSize:16];
    timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    timeLabel.numberOfLines = 0;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    if (!item.title ) {
        [timeLabel setText:@"unknow"];
    }else{
        [timeLabel setText:@"time"];
    }
    [bgView addSubview:timeLabel];
    
    
    UILabel *singerLabel = [[UILabel alloc]initWithFrame:CGRectMake(350, 10, 150, 30)];
    singerLabel.font = [UIFont systemFontOfSize:16];
    singerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    singerLabel.numberOfLines = 0;
    singerLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.artist) {
        [singerLabel setText:@"unknow"];
    }else{
        [singerLabel setText:item.artist];
    }
    
    [bgView addSubview:singerLabel];
    
    
    UILabel *albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(550, 10, 150, 30)];
    albumNameLabel.font = [UIFont systemFontOfSize:16];
    albumNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    albumNameLabel.numberOfLines = 0;
    albumNameLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.albumArtURI) {
        [albumNameLabel setText:@"unknow"];
    }else{
        [albumNameLabel setText:item.albumArtURI];
    }
    
    [bgView addSubview:albumNameLabel];
    
    
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(750, 10, 90, 30)];
    dateLabel.font = [UIFont systemFontOfSize:16];
    dateLabel.lineBreakMode = NSLineBreakByCharWrapping;
    dateLabel.numberOfLines = 0;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    if (!item.mimeType ) {
        [dateLabel setText:@"unknow"];
    }else{
        [dateLabel setText:item.mimeType];
    }
    
    [bgView addSubview:dateLabel];
    
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(850, 10, 100, 30)];
    typeLabel.font = [UIFont systemFontOfSize:16];
    typeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    typeLabel.numberOfLines = 0;
    typeLabel.textAlignment = NSTextAlignmentCenter;
    if (!item.codeType) {
        [typeLabel setText:@"unknow"];
    }else{
        [typeLabel setText:item.codeType];
    }
    [bgView addSubview:typeLabel];
    
    if(islist){
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
        NSString *stringimage=[NSString stringWithFormat:@"%@",item.smallImageUrl];
        if (!stringimage) {
            [headImageView setImage:[UIImage imageNamed:@"temp"]];
            
            
        }else{
            [headImageView setImage:[UIImage imageNamed:@"temp"]];
        }
        [bgView addSubview:headImageView];
    }
    
    
    
    
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
