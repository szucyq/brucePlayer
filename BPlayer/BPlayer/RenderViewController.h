//
//  RenderViewController.h
//  BPlayer
//
//  Created by Bruce on 15/6/28.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import "WithTableViewController.h"
//#import <MediaServerBrowserService/MediaRenderControllerService.h>

@interface RenderViewController : WithTableViewController
@property (nonatomic,retain)NSIndexPath *lastIndexPath;
- (id)initWithFrame:(CGRect)frame;
@end
