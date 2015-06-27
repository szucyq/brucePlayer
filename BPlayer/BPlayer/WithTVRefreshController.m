//
//  WithTVRefreshController.m
//  uulife
//
//  Created by Bruce on 15-4-30.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithTVRefreshController.h"

@interface WithTVRefreshController ()

@end

@implementation WithTVRefreshController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    
    [self.listTableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    [self.listTableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    
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
- (void)loadNewData{
    NSLog(@"loadNewData");
//    [self.listTableView.legendHeader beginRefreshing];
}
- (void)loadMoreData{
    NSLog(@"loadMoreData");
}
- (void)endRefreshAction{
//    [self.listTableView he];
//    [self.listTableView footerEndRefreshing];
}
@end
