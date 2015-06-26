//
//  MediaServerBrowserService.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/24.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

//! Project version number for MediaServerBrowserService.
FOUNDATION_EXPORT double MediaServerBrowserServiceVersionNumber;

//! Project version string for MediaServerBrowserService.
FOUNDATION_EXPORT const unsigned char MediaServerBrowserServiceVersionString[];

// In this header, you should import all the public headers of your framework using statements like#import <MediaServerBrowserService/PublicHeader.h>

@class MediaServerBrowser;

enum MediaServerItemType {
    UNKNOW = 0,
    VIDEO,
    AUDIO,
    IMAGE,
    FOLDER
};

@interface MediaServerItem : NSObject


@property (nonatomic, strong) NSString *objID;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *uri;

@property (nonatomic) NSInteger size;

@property (nonatomic) enum MediaServerItemType type;

@end

@protocol MediaServerBrowserServiceDelegate <NSObject>

- (BOOL)onMediaServerBrowserAdded:(NSString*)friendlyName uuid:(NSString*)uuid;

- (void)onMediaServerBrowserRemoved:(NSString*)friendlyName uuid:(NSString*)uuid;

@end


@interface MediaServerBrowserService : NSObject

+ (id)instance;

- (BOOL)startService:(id)delegate;

- (void)stopService;

///创建
- (MediaServerBrowser*)browserWithUUID:(NSString*)uuid delegate:(id)delegate;

- (void)destroyBrowser:(MediaServerBrowser*)browser;

///查询
- (MediaServerBrowser*)findBrowser:(NSString*)uuid;
@end

@protocol MediaServerBrowserDelegate <NSObject>

///@params items out array of MediaServerItem*
- (void)onBrowseResult:(int)res
                  path:(NSString*)path
                 items:(NSArray*)items;

@end

@interface MediaServerBrowser : NSObject

- (void)browseRoot;

- (void)browse:(NSString*)objID;

@property(nonatomic, readonly) NSString* uuid;

@property(nonatomic, readonly) NSString* friendlyName;

@property(nonatomic, readonly) id delegate;

@end