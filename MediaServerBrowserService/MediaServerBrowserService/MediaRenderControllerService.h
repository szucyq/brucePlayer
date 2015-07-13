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
- (void)getCurPos:(void (^)(BOOL,NSTimeInterval))handler;

- (void)getVolume:(void (^)(BOOL,NSInteger))handler;

- (void)getCurUri:(void (^)(BOOL,NSString*))handler;

- (void)getStat:(void (^)(BOOL,int))handler;

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