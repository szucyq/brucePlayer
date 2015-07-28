//
//  MediaServerCrawler.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerCrawler.h"

#import "MediaServerBrowserService.h"

@interface MediaServerCrawler() {
    void (^callback_)(BOOL ret, NSArray*items);
}

@property (nonatomic) MediaServerBrowser *browser;
@property (nonatomic) NSMutableArray *dirArr;
@property (nonatomic) NSMutableArray *crawlItemArr;

@end

@implementation MediaServerCrawler

@synthesize browser = browser_;

@synthesize dirArr = dirArr_;

@synthesize crawlItemArr = crawlItemArr_;

@synthesize isCrawling = isCrawling_;

- (id)initWithBrowser:(MediaServerBrowser *)browser
{
    
    self = [super init];
    if ( self ) {
        browser_ = browser;
        crawlItemArr_ = [[NSMutableArray alloc] init];
        isCrawling_ = NO;
    }
    return self;
}

- (void)browseFolder
{
    NSString *path = [dirArr_ firstObject];
    NSLog(@"[MediaServerCrawler] [browseFolder] path = %@", path);
    if ( path == nil ) { //遍历结束
        callback_(YES, [crawlItemArr_ copy]);
        isCrawling_ = NO;
        return;
    }
    [browser_ browse:path handler:^(BOOL ret, NSString *objID, NSArray *items) {
        [dirArr_ removeObject:objID];
        if (ret) {
            for ( NSInteger i=0; i<items.count; i++ ) {
                MediaServerItem *item = [items objectAtIndex:i];
                switch (item.type) {
                    case FOLDER:
                        [dirArr_ addObject:item.objID];
                        break;
                    case AUDIO:
                        NSLog(@"[MediaServerCrawler] [onBrowseResult] add %@", item.title);
                        [crawlItemArr_ addObject:item];
                        break;
                    default:
//                        NSLog(@"[MediaServerCrawler] [onBrowseResult] add %@", item.title);
//                        [crawlItemArr_ addObject:item];
                        break;
                }
            }
        } else {
            NSLog(@"[MediaServerCrawler] [onBrowseResult] failure!!!");
        }
        [self browseFolder];
    }];
}

- (void)crawl:(void (^)(BOOL ret, NSArray*items))handler
{
    if ( isCrawling_ )
        return;
    isCrawling_ = YES;
    callback_ = handler;
    dirArr_ = [[NSMutableArray alloc] init];
    [dirArr_ addObject:@"0"];
    [self browseFolder];
}
@end
