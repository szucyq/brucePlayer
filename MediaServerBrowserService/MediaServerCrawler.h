//
//  MediaServerCrawler.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaServerBrowserService/MediaServerBrowserService.h"

@interface MediaServerCrawler : NSObject

- (id)initWithBrowser:(MediaServerBrowser*)browser;

- (void)crawl:(void (^)(BOOL ret, NSArray*items))handler;

@property (nonatomic, readonly) BOOL isCrawling;

@end
