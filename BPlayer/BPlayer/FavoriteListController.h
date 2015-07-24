//
//  RenderViewController.h
//  BPlayer
//
//  Created by Bruce on 15/6/28.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithTableViewController.h"
//#import <MediaServerBrowserService/MediaRenderControllerService.h>

@interface FavoriteListController : WithTableViewController
@property (nonatomic,retain)NSIndexPath *lastIndexPath;
@property (nonatomic,retain)NSMutableDictionary *renderDic;
- (id)initWithFrame:(CGRect)frame;
@end
