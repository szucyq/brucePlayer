//
//  MediaServerCrawler.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MediaServerCrawlerDelegate <NSObject>

- (void)onCrawlResult:(NSArray*)items;

@end

@interface MediaServerCrawler : NSObject

- (id)initWithUUID:(NSString*)UUID delegate:(id)delegate;

- (void)crawl;

@end
