//
//  WithTableViewController.m
//  uulife
//
//  Created by Bruce on 15-4-27.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithTableViewController.h"

@interface WithTableViewController ()

@end

@implementation WithTableViewController
- (id)init{
    self=[super init];
    if(self){
        self.listArray=[NSMutableArray array];
        self.currentPage=1;
        //添加list table view
        UITableView *tv=[[UITableView alloc]initWithFrame:CGRectMake(0, kContentBaseY, kContentViewWidth, kContentViewHeightNoTab) style:UITableViewStylePlain];
        NSLog(@"super tv rect :%@",[NSValue valueWithCGRect:tv.frame]);
        self.listTableView=tv;
        self.listTableView.delegate=self;
        self.listTableView.dataSource=self;
        [self.view addSubview:self.listTableView];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier=@"roomListCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    return cell;
}
@end
