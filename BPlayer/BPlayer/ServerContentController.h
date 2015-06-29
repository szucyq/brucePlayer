//
//  ItemsViewController.h
//  MediaBrowserTest
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaServerBrowserService/MediaServerBrowserService.h>



@interface ServerContentController : UITableViewController

@property (nonatomic, strong) MediaServerBrowser* browser;
@property (nonatomic,copy)NSString *browseID;
@property (nonatomic,retain)ServerContentController *serverContentController;

- (id)initWithFrame:(CGRect)frame root:(BOOL)rootOrNot objectId:(NSString*)anObjectId;
@end
