//
//  ServerContentViewController.h
//  BPlayer
//
//  Created by Bruce on 15/6/30.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaServerBrowserService/MediaServerBrowserService.h>


@interface ServerContentViewController : UITableViewController<MediaServerBrowserDelegate>

@property (nonatomic, retain) MediaServerBrowser* browser;


- (id)initWithFrame:(CGRect)frame root:(BOOL)rootOrNot objectId:(NSString*)anObjectId;
@end
