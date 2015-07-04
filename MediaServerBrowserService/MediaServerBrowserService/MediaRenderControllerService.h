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

@interface MediaRenderController : NSObject

enum RenderStatu{
    STOPED = 0,
    PLAYING,
    PAUSED,
    LOADING
};
//get
@property(nonatomic, readonly)NSString *UUID;
@property(nonatomic, readonly)NSString *friendlyName;

// async get
- (void)getCurPos:(void*)userData;

- (void)getVolume:(void*)userData;

- (void)getCurUri:(void*)userData;

- (void)getStat:(void*)userData;

//set
- (void)setUri:(NSString*)url name:(NSString*)name handler:(void (^)(BOOL))handler;

- (void)play:(void*)userData;

- (void)pause:(void*)userData;

- (void)stop:(void*)userData;

- (void)seek:(NSTimeInterval)pos userData:(void*)userData;

- (void)setVolume:(int)vol userData:(void*)userData;

@end