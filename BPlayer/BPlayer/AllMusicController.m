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
#define kUnknownAlertString @"Unknown"

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
    self.view.backgroundColor=[UIColor whiteColor];
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
    [self getAllMusicData];
}
-(void)addscroller{
    //
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int imageWidth=[[defaults valueForKey:kIconWidth] intValue];
    int imagecount=[[defaults valueForKey:kIconNumber] intValue];
    int imageHeight=[[defaults valueForKey:kIconHeight] intValue];
    NSLog(@"width1:%d--number1:%d",imageWidth,imagecount);
    if(imagecount==0 || imageWidth==0 || imageHeight==0){
        imageWidth=120;
        imagecount=7;
        imageHeight=120;
    }
    NSLog(@"width:%d--number:%d",imageWidth,imagecount);

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
//    [scrollerview addGestureRecognizer:pinchGestureRecognizer];
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    [self.scrollView addSubview:scrollerview];
    
    
    
    
    
    float paddingX=(kMusicViewWidth-imagecount*imageWidth)/(imagecount+1);
    float paddingY=paddingX+40;
    float baseY=-40;
    
    for (int i=0; i<self.listArray.count; i++) {
        MediaServerItem *record=[self.listArray objectAtIndex:i];
        
        float x=i%imagecount*(imageWidth)+(i%imagecount+1)*paddingX;
        float y=i/imagecount*(imageHeight)+(i/imagecount+1)*paddingY+baseY;
//        NSLog(@"x:%f--y:%f",x,y);
        UIImageView *iconimage=[[UIImageView alloc]initWithFrame:CGRectMake(x, y, imageWidth, imageHeight)];
        NSString *stringimage=record.albumArtURI;
        if ([stringimage isEqualToString:@"(null)"]) {
            [iconimage setImage:[UIImage imageNamed:@"temp"]];
        }else{
            [iconimage setImage:[UIImage imageNamed:@"temp"]];
        }
        [self.scrollView addSubview:iconimage];
        
        
        UIButton * imagebutton=[[UIButton alloc]initWithFrame:CGRectMake(x, y, imageWidth, imageHeight)];
        imagebutton.tag=i+1000;
        [imagebutton addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:imagebutton];
        
        UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(x, y+imageWidth, imageWidth, 20)];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.textAlignment = NSTextAlignmentCenter;
        titleText.font            = [UIFont systemFontOfSize:14.0];
        if(record.title){
            [titleText setText:record.title];
        }
        else{
            [titleText setText:[NSString stringWithFormat:@"%@%d",@"music:",i+1]];
        }
        
        [self.scrollView addSubview:titleText];
        
        UILabel *detailText = [[UILabel alloc] initWithFrame: CGRectMake(x, y+imageWidth+20, imageWidth, 20)];
        detailText.backgroundColor = [UIColor clearColor];
        detailText.textAlignment = NSTextAlignmentCenter;
        detailText.font            = [UIFont systemFontOfSize:12.0];
        if(record.album){
          [detailText setText:record.album];
        }
        else{
            [detailText setText:kUnknownAlertString];
        }
        [self.scrollView addSubview:detailText];
        
        
    }
    float sizeHeight=(self.listArray.count/imagecount+1)*(imageHeight+paddingY);
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
    NSInteger i=[sender tag]-1000;
    MediaServerItem *item=[self.listArray objectAtIndex:i];
    //如果是音频文件播放，则要在主界面控制
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
}
- (void)setByType:(NSString *)byType{
    [self.listArray removeAllObjects];
    [self getAllMusicData];
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
        [self showlistAction];
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
    CGFloat factor = [(UIPinchGestureRecognizer *) recognizer scale];
    NSLog(@"scale is :%f",factor);
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int imagecount=[[defaults valueForKey:kIconNumber] intValue];
    
    if(imagecount==0)
        imagecount=7;
    NSLog(@"iamgecount :%d",imagecount);
    if(factor>=1){
        //放大手势
        if(imagecount==7){
            //6
            [defaults setObject:@"6" forKey:kIconNumber];
            [defaults setObject:@"130" forKey:kIconWidth];
            [defaults setObject:@"130" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
        if(imagecount==6){
            //5
            [defaults setObject:@"5" forKey:kIconNumber];
            [defaults setObject:@"140" forKey:kIconWidth];
            [defaults setObject:@"140" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
        if(imagecount==5){
            //4
            [defaults setObject:@"4" forKey:kIconNumber];
            [defaults setObject:@"150" forKey:kIconWidth];
            [defaults setObject:@"150" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
        
    }
    else{
        //缩小手势
        if(imagecount==4){
            //5
            [defaults setObject:@"5" forKey:kIconNumber];
            [defaults setObject:@"140" forKey:kIconWidth];
            [defaults setObject:@"140" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
        if(imagecount==5){
            //6
            [defaults setObject:@"6" forKey:kIconNumber];
            [defaults setObject:@"130" forKey:kIconWidth];
            [defaults setObject:@"130" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
        if(imagecount==6){
            //7
            [defaults setObject:@"7" forKey:kIconNumber];
            [defaults setObject:@"120" forKey:kIconWidth];
            [defaults setObject:@"120" forKey:kIconHeight];
            [defaults synchronize];
            [self addscroller];
            return;
        }
    }
    
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
- (void)getAllMusicData{
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    
    
    if(!appDelagete.serverUuid){
        NSLog(@"server uuid :%@",appDelagete.serverUuid);
        [self.listArray removeAllObjects];
        return;
    }
    NSLog(@"server uuid :%@",appDelagete.serverUuid);
    
    NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"select * from music where server='",appDelagete.serverUuid,@"';"];
//    NSString *sql=[NSString stringWithFormat:@"%@",@"select * from music;"];
    //查询数据
    [CoreFMDB executeQuery:sql queryResBlock:^(FMResultSet *set) {
        
        while ([set next]) {
            NSLog(@"%@-%@",[set stringForColumn:@"title"],[set stringForColumn:@"uri"]);
            //date
            NSString *dateStr=[set stringForColumn:@"date"];
//            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
//            dateFormatter.dateFormat= @"yyyy-MM-dd";
//            NSDate *date=[dateFormatter dateFromString:dateStr];
//            NSLog(@"date:%@",date);
            //duration
            NSString *durationStr=[set stringForColumn:@"duration"];
            NSTimeInterval duration=[durationStr floatValue];

            
            MediaServerItem *item=[[MediaServerItem alloc]init];
            item.title=[set stringForColumn:@"title"];
            item.uri=[set stringForColumn:@"uri"];
            item.composer=[set stringForColumn:@"composer"];
            item.date=dateStr;
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
}
NSString *stringFromInterval(NSTimeInterval timeInterval)
{
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
    //    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
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
    NSLog(@"showlistAction:%@",self.listArray);
    islistIcon=NO;
    isicon=NO;
    islist=YES;
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
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"albumArtURI"
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
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"composer"
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
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date"
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
#pragma mark -
#pragma mark 收藏
- (BOOL)isFavourite:(NSString*)uri{
    NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"select * from favourite where uri='",uri,@"';"];
    NSLog(@"check sql:%@",sql);
    __block BOOL isFavourite=NO;
    [CoreFMDB executeQuery:sql queryResBlock:^(FMResultSet *set){
        NSLog(@"result:%@",[set resultDictionary]);
        while ([set next]) {
            NSLog(@"t:%@",[set stringForColumn:@"title"]);
            isFavourite=YES;
        }
        
    }];

    return isFavourite;
}
- (void)favouriteAction:(id)sender{
    UIButton *bt=(UIButton*)sender;
    NSLog(@"tag:%ld",bt.tag);
    MediaServerItem *item=[self.listArray objectAtIndex:bt.tag];
    AppDelegate* appDelagete = [[UIApplication sharedApplication] delegate];
    //先判断是要收藏还是要取消收藏
    if([self isFavourite:item.uri]){
        //已经收藏了，则取消
        NSString *sql=[NSString stringWithFormat:@"%@%@%@",@"delete from favourite where uri='",item.uri,@"';"];
        BOOL musicRemove=[CoreFMDB executeUpdate:sql];
        if(musicRemove){
            NSLog(@"success:%@",item.title);
            [bt setImage:[UIImage imageNamed:@"menu_favourite.png"] forState:UIControlStateNormal];
        }
        else{
            NSLog(@"fail:%@",item.title);
        }
    }
    else{
       //没有收藏过，则收藏
        NSString *title=[NSString stringWithFormat:@"%@",item.title];
        NSString *uri=[NSString stringWithFormat:@"%@",item.uri];
        NSString *composer=[NSString stringWithFormat:@"%@",item.composer];
        NSString *album=[NSString stringWithFormat:@"%@",item.album];
        
        NSString *genres=@"";
        for(id obj in item.genres){
            if(![obj isEqual:[NSNull null]] && obj!=nil){
                NSString *str;
                if(genres.length>0){
                    str=[NSString stringWithFormat:@"%@%@",@"/",obj];
                }
                else{
                    str=[NSString stringWithFormat:@"%@",obj];
                }
                genres=[genres stringByAppendingString:str];
            }
            
        }
        
        //date
        //                NSString *date=[NSString stringWithFormat:@"%@",item.date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        dateFormatter.dateFormat= @"yyyy-MM-dd";
        NSString *date=[dateFormatter stringFromDate:item.date];
        //    NSLog(@"date:%@",date);
        //
        NSString *format=[NSString stringWithFormat:@"%@",item.contentFormat];
        //duration
        NSTimeInterval durationDouble=item.duration;
        NSString *duration=[NSString stringWithFormat:@"%f",durationDouble];
        //    NSLog(@"duration:%f",durationDouble);
        
        NSString *sql=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"insert into favourite (server,title,uri,composer,album,genres,date,format,duration) values('",appDelagete.serverUuid,@"','",title,@"','",uri,@"','",composer,@"','",album,@"','",genres,@"','",date,@"','",format,@"','",duration,@"');"];
        
            NSLog(@"add fav sql:%@",sql);
        BOOL musicAdd=[CoreFMDB executeUpdate:sql];
        if(musicAdd){
            NSLog(@"success:%@",item.title);
            [bt setImage:[UIImage imageNamed:@"menu_favourite_select.png"] forState:UIControlStateNormal];
        }
        else{
            NSLog(@"fail:%@",item.title);
        }
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

    for(UIView *view in cell.subviews){
        [view removeFromSuperview];
    }
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMusicViewWidth, kMusicTableRowHeigth)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:bgView];
    

    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    //----------标题列
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 120, 30)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.title ) {
        [titleLabel setText:kUnknownAlertString];
    }else{
        [titleLabel setText:item.title];
    }
    [bgView addSubview:titleLabel];
    
    //时长列
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 30)];
    timeLabel.font = [UIFont systemFontOfSize:16];
    timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    timeLabel.numberOfLines = 0;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    if (!item.duration ) {
        [timeLabel setText:kUnknownAlertString];
    }else{
        [timeLabel setText:stringFromInterval(item.duration)];
    }
    [bgView addSubview:timeLabel];
    
    //artist
    UILabel *singerLabel = [[UILabel alloc]initWithFrame:CGRectMake(350, 10, 150, 30)];
    singerLabel.font = [UIFont systemFontOfSize:16];
    singerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    singerLabel.numberOfLines = 0;
    singerLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.artist) {
        [singerLabel setText:kUnknownAlertString];
    }else{
        [singerLabel setText:item.artist];
    }
    
    [bgView addSubview:singerLabel];
    
    //album
    UILabel *albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(550, 10, 150, 30)];
    albumNameLabel.font = [UIFont systemFontOfSize:16];
    albumNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    albumNameLabel.numberOfLines = 0;
    albumNameLabel.textAlignment = NSTextAlignmentLeft;
    if (!item.album) {
        [albumNameLabel setText:kUnknownAlertString];
    }else{
        [albumNameLabel setText:item.album];
    }
    
    [bgView addSubview:albumNameLabel];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(750, 10, 90, 30)];
    dateLabel.font = [UIFont systemFontOfSize:16];
    dateLabel.lineBreakMode = NSLineBreakByCharWrapping;
    dateLabel.numberOfLines = 0;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    if (!item.date ) {
        [dateLabel setText:kUnknownAlertString];
    }else{
        
//        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
//        dateFormatter.dateFormat= @"yyyy-MM-dd";
//        NSDate *date=item.date;
//        NSString *dateStr=[dateFormatter stringFromDate:date];
        [dateLabel setText:item.date];
    }
    
    [bgView addSubview:dateLabel];
    
    //风格
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(850, 10, 100, 30)];
    typeLabel.font = [UIFont systemFontOfSize:16];
    typeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    typeLabel.numberOfLines = 0;
    typeLabel.textAlignment = NSTextAlignmentCenter;
    if (item.genres.count==0) {
        [typeLabel setText:kUnknownAlertString];
    }else{
        NSString *genres=@"";
        for(id obj in item.genres){
            if(![obj isEqual:[NSNull null]] && obj!=nil){
                genres=[genres stringByAppendingString:obj];
            }
            
        }
        [typeLabel setText:genres];
    }
    [bgView addSubview:typeLabel];
    
    
    
    //根据模式选择是否显示小图标
    if(islistIcon){
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
        NSString *stringimage=[NSString stringWithFormat:@"%@",item.albumArtURI];
        if (!stringimage) {
            [headImageView setImage:[UIImage imageNamed:@"temp"]];
            
            
        }else{
            [headImageView setImage:[UIImage imageNamed:@"temp"]];
        }
        [bgView addSubview:headImageView];
    }
    //收藏按钮
    UIButton *favBt=[UIButton buttonWithType:UIButtonTypeCustom];
    favBt.frame=CGRectMake(kContentViewWidth-60, 0, 60, 60);
    [favBt addTarget:self action:@selector(favouriteAction:) forControlEvents:UIControlEventTouchUpInside];
    favBt.tag=indexPath.row;
    
    if([self isFavourite:item.uri]){
        [favBt setImage:[UIImage imageNamed:@"menu_favourite_select.png"] forState:UIControlStateNormal];
    }
    else{
        [favBt setImage:[UIImage imageNamed:@"menu_favourite.png"] forState:UIControlStateNormal];
    }
    [bgView addSubview:favBt];
    //点击cell颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor=[UIColor blueColor];
    //奇偶行颜色
    UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
    NSLog(@"点击:%ld",indexPath.row%2);
    if(indexPath.row%2){
        //偶
        backgrdView.backgroundColor = [UIColor whiteColor];
        cell.backgroundView=backgrdView;
    }
    else{
        backgrdView.backgroundColor = RGB(236, 234, 234, 1);
        cell.backgroundView=backgrdView;
    }
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 40;
    }
    return 0;
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    float y=5;
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kContentViewWidth, 40)];
    //title
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, y, 120, 30)];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text=@"标题";
    [view addSubview:titleLabel];
    
    //长度
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, y, 100, 30)];
    timeLabel.font = [UIFont systemFontOfSize:16];
    timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    timeLabel.numberOfLines = 0;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text=@"时长";
    [view addSubview:timeLabel];
    
    //artist
    UILabel *singerLabel = [[UILabel alloc]initWithFrame:CGRectMake(350, y, 150, 30)];
    singerLabel.font = [UIFont systemFontOfSize:16];
    singerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    singerLabel.numberOfLines = 0;
    singerLabel.textAlignment = NSTextAlignmentLeft;
    singerLabel.text=@"艺术家";
    [view addSubview:singerLabel];
    
    
    //album
    UILabel *albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(550, y, 150, 30)];
    albumNameLabel.font = [UIFont systemFontOfSize:16];
    albumNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    albumNameLabel.numberOfLines = 0;
    albumNameLabel.textAlignment = NSTextAlignmentLeft;
    albumNameLabel.text=@"专辑";
    
    [view addSubview:albumNameLabel];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(750, y, 90, 30)];
    dateLabel.font = [UIFont systemFontOfSize:16];
    dateLabel.lineBreakMode = NSLineBreakByCharWrapping;
    dateLabel.numberOfLines = 0;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.text=@"日期";
    
    [view addSubview:dateLabel];
    
    //风格
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(850, y, 100, 30)];
    typeLabel.font = [UIFont systemFontOfSize:16];
    typeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    typeLabel.numberOfLines = 0;
    typeLabel.textAlignment = NSTextAlignmentCenter;
    typeLabel.text=@"风格";
    [view addSubview:typeLabel];
    
    view.backgroundColor=[UIColor whiteColor];
    return view;
    
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here, for example:
    MediaServerItem *item=[self.listArray objectAtIndex:indexPath.row];
    //如果是音频文件播放，则要在主界面控制
    NSDictionary *userinfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"item", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kPlay" object:nil userInfo:userinfo];
}

@end
