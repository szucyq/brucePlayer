//
//  MediaRenderControllerService.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/27.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaRenderController;

///dmr控制服务
///@note MediaRenderAddedNotification dms服务器上线
///      MediaRenderRemovedNotification dms服务器下线
@interface MediaRenderControllerService : NSObject

+ (instancetype)instance;

- (BOOL)startService;

- (void)stopService;

- (MediaRenderController*)controllerWithUUID:(NSString*)UUID;

///获取所有在线的render
///@note key = UUID, value = friendlyName
@property (nonatomic, readonly)NSDictionary *renderDic;

@property (nonatomic, readonly)BOOL isRunning;
@end

@class MediaItemInfo;

@interface MediaRenderController : NSObject

enum RenderStatu{
    STOPED = 0,
    PLAYING,
    PAUSED,
    LOADING,
    STAT_UNKNOW
};

//get
@property(nonatomic, readonly)NSString *UUID;
@property(nonatomic, readonly)NSString *friendlyName;

@property(nonatomic, readonly)NSNumber *state;
@property(nonatomic, readonly)NSNumber *duration;
@property(nonatomic, readonly)NSNumber *volume;
@property(nonatomic, readonly)NSString *title;

// async get
- (void)getCurPos:(void (^)(BOOL,NSTimeInterval,NSTimeInterval))handler;

- (void)getVolume:(void (^)(BOOL,NSInteger))handler;

- (void)getCurUri:(void (^)(BOOL,NSString*))handler;

- (void)getStat:(void (^)(BOOL,int))handler;

- (void)getMediaInfo:(void (^)(BOOL,MediaItemInfo*))handler;

- (void)next:(void (^)(BOOL))handler;

- (void)previous:(void (^)(BOOL))handler;

//set
- (void)setUri:(NSString*)url name:(NSString*)name handler:(void (^)(BOOL))handler;

- (void)play:(void (^)(BOOL))handler;

- (void)pause:(void (^)(BOOL))handler;

- (void)stop:(void (^)(BOOL))handler;

- (void)seek:(NSTimeInterval)pos handler:(void (^)(BOOL))handler;

- (void)setVolume:(int)vol handler:(void (^)(BOOL))handler;

- (void)setMute:(BOOL)isMute handler:(void (^)(BOOL))handler;
@end

@interface MediaItemInfo :NSObject

@property (nonatomic, strong) NSString *curUrl;

@property (nonatomic, strong) NSString *nextUrl;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *iconUri;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) NSInteger bitRate;

@property (nonatomic, strong) NSString *extention;

//@property (nonatomic, strong) NSString* format;
@end