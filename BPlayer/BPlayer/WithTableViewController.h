//
//  WithTableViewController.h
//  uulife
//
//  Created by Bruce on 15-4-27.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithLeftRightController.h"

@interface WithTableViewController : WithLeftRightController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain)UITableView *listTableView;
@property (nonatomic,retain)NSMutableArray *listArray;
@property (nonatomic)NSInteger currentPage;
- (id)init;
@end
