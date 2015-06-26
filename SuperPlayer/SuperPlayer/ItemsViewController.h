//
//  ItemsViewController.h
//  MediaBrowserTest
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaServerBrowserService/MediaServerBrowserService.h>

@interface ItemsViewController : UITableViewController

@property (nonatomic, strong) MediaServerBrowser* browser;

@end
