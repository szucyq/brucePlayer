//
//  MediaServerCrawler.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerCrawler.h"

#import "MediaServerBrowserService.h"

@interface MediaServerCrawler()<MediaServerBrowserDelegate>

@property (nonatomic) id delegate;
@property (nonatomic) MediaServerBrowser *browser;
@property (nonatomic) NSMutableArray *dirArr;
@property (nonatomic) NSMutableArray *crawlItemArr;
@end

@implementation MediaServerCrawler

@synthesize delegate = delegate_;

@synthesize browser = browser_;

@synthesize dirArr = dirArr_;

@synthesize crawlItemArr = crawlItemArr_;

- (id)initWithUUID:(NSString*)UUID delegate:(id)delegate
{
    self = [super init];
    if ( self ) {
        delegate_ = delegate;
        browser_ = [[MediaServerBrowserService instance] browserWithUUID:UUID delegate:self];
        dirArr_ = [[NSMutableArray alloc] init];
        [dirArr_ addObject:@"0"];
        crawlItemArr_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)onBrowseResult:(int)res path:(NSString *)path items:(NSArray *)items
{
    if (res == 0) {
        [dirArr_ removeObject:path];
        for (NSInteger i=0; i<items.count; i++ ) {
            MediaServerItem *item = [items objectAtIndex:i];
            switch (item.type) {
                case FOLDER:
                    [dirArr_ addObject:item.objID];
                    break;
                default:
                    NSLog(@"[MediaServerCrawler] [onBrowseResult] add %@", item.title);
                    [crawlItemArr_ addObject:item];
                    
                    break;
            }
        }
        if ( [dirArr_ count] == 0 ) {
            if ( [delegate_ respondsToSelector:@selector(onCrawlResult:)] ) {
                [delegate_ onCrawlResult:crawlItemArr_==nil?nil:[crawlItemArr_ copy]];
            }
        } else {
            [self crawl];
        }
    } else {
        NSLog(@"[MediaServerCrawler] [onBrowseResult] failure!!!");
    }
}

- (void)crawl
{
    NSString *path = [dirArr_ firstObject];
    if (path == nil) {
        return;
    }
    NSLog(@"[MediaServerCrawler] [crawl] path = %@", path);
    [browser_ browse:path];
}
@end
