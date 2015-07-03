//
//  AllMusicController.h
//  SuperPlayer
//
//  Created by Bruce on 15/6/26.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithTableViewController.h"
#import <MediaServerBrowserService/MediaServerCrawler.h>
@interface AllMusicController : WithTableViewController
@property (nonatomic,copy)NSString *byType;
@property (nonatomic,copy)NSString *serverUuid;
- (id)initWithFrame:(CGRect)frame;
@end
