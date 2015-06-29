//
//  MediaRenderControllerService.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/27.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaRenderController;

@protocol MediaRenderControllerServiceDelegate <NSObject>

- (BOOL)onMediaRenderAdded:(NSString*)friendlyName UUID:(NSString*)UUID;

- (void)onMediaRenderRemoved:(NSString*)friendlyName UUID:(NSString*)UUID;

@end

@interface MediaRenderControllerService : NSObject

+ (id)instance;

- (BOOL)startService:(id)delegate;

- (void)stopService;

- (MediaRenderController*)controllerWithUUID:(NSString*)UUID;

@end

@interface MediaRenderController : NSObject

enum RenderStatu{
    UNKNOW = 0,
    PLAYING,
    PAUSED,
    STOPED,
    LOADING
};
//get
@property(nonatomic, readonly)NSString *UUID;
@property(nonatomic, readonly)NSString *friendlyName;
@property(nonatomic, readonly)id delegate;

// async get
- (void)getCurPos:(void*)userData;

- (void)getVolume:(void*)userData;

- (void)getCurUri:(void*)userData;

- (void)getStat:(void*)userData;

//set
- (void)setUri:(NSURL*)url userData:(void*)userData;

- (void)play:(void*)userData;

- (void)pause:(void*)userData;

- (void)stop:(void*)userData;

- (void)seek:(NSTimeInterval)pos userData:(void*)userData;

- (void)setVolume:(int)vol userData:(void*)userData;

@end