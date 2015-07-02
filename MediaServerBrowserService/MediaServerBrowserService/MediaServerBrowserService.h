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

///DMS浏览服务器
///@note MediaServerAddedNotification dms服务器上线
///      MediaServerRemovedNotification dms服务器下线
@interface MediaServerBrowserService : NSObject

+ (instancetype)instance;

///启动服务
- (BOOL)startService;

///停止服务
///@note DMSRemovedNotification会被触发
- (void)stopService;

///创建DMS浏览对象
///@param [in] uuid dms唯一标示
- (MediaServerBrowser*)browserWithUUID:(NSString*)uuid;

///在线的DMS
@property (nonatomic, readonly) NSDictionary *mediaServers;

@end


@interface MediaServerBrowser : NSObject

;
///浏览根目录
- (void)browseRoot:(void (^)(BOOL ret, NSString* objID, NSArray*items))handler;

///浏览dms中某一个目录
///@param[in] objID 文件夹object ID
- (void)browse:(NSString*)objID handler:(void (^)(BOOL ret, NSString *objID, NSArray*items))handler;

///唯一标示
@property(nonatomic, readonly) NSString* UUID;

@property(nonatomic, readonly) NSString* friendlyName;

@end

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

@property (nonatomic) NSUInteger size;

@property (nonatomic) enum MediaServerItemType type;

@property (nonatomic, strong) NSString *artist;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *composer;

@property (nonatomic, strong) NSString *trackList;

@property (nonatomic, strong) NSString *codeType;

@property (nonatomic, strong) NSString *contentFormat;

@property (nonatomic, strong) NSString *mimeType;

@property (nonatomic, strong) NSString *extention;

@property (nonatomic, strong) NSString *albumArtURI;

@property (nonatomic, strong) NSString *thumbnailUrl;

@property (nonatomic, strong) NSString *smallImageUrl;

@property (nonatomic, strong) NSString *mediumImageUrl;

@property (nonatomic, strong) NSString *largeImageUrl;
@end