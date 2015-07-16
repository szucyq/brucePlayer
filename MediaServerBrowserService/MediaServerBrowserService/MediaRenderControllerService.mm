//
//  MediaRenderControllerService.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/27.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaRenderControllerService.h"

#include "Platinum/Platinum.h"
#include "upnpdeamon.h"
#include "MediaRenderControllerServiceListener.h"

#import "MediaRenderControllerImpl.h"

class MediaRenderLinster;

@implementation MediaRenderControllerService
{
    NPT_Reference<PLT_MediaController> controller_;
    PLT_CtrlPointReference ctrlPoint_;
    NSMutableDictionary *controllerDic_;
    MediaRenderControllerServiceListener *listener_;
}

+ (instancetype)instance
{
    static MediaRenderControllerService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MediaRenderControllerService alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        controllerDic_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)isRunning
{
    return controller_.IsNull() ? NO : YES;
}

- (BOOL)startService
{
    if ( self.isRunning ) {
        NSLog(@"[MediaRenderControllerService] [startService] services is already start");
        return YES;
    }
    if (ctrlPoint_.IsNull()) {
        ctrlPoint_ = new PLT_CtrlPoint();
    }
    listener_ = new MediaRenderControllerServiceListener();
    controller_ = new PLT_MediaController(ctrlPoint_, listener_);
    UPnPDeamon::instance()->addCtrlPoint(ctrlPoint_);
    return YES;
}

- (void)stopService
{
    if ( !self.isRunning ) {
        NSLog(@"[MediaRenderControllerService] [stopService] services isn't start");
        return;
    }
    UPnPDeamon::instance()->removeCtrlPoint(ctrlPoint_);
    [controllerDic_ removeAllObjects];
    controller_.Detach();
    delete listener_;
    listener_ = NULL;
}

- (MediaRenderController*)controllerWithUUID:(NSString*)UUID
{
    //NSLog(@"[MediaRenderControllerService] [controllerWithUUID] uuid = %@", UUID);
    MediaRenderController *controller = [controllerDic_ objectForKey:UUID];
    if ( controller == nil ) {
        PLT_DeviceDataReference device;
        NPT_Result res = controller_->FindRenderer([UUID UTF8String], device);
        if ( NPT_SUCCEEDED(res) ) {
            controller = [[MediaRenderControllerImpl alloc] initWithController:device controller:controller_.AsPointer()];
            [controllerDic_ setObject:controller forKey:UUID];
        }
    }
    return controller;
}

- (NSDictionary*)renderDic
{
    return listener_ == NULL ? nil: listener_->allRenders();
}

@end

@implementation MediaItemInfo

@synthesize curUrl;
@synthesize duration;
@synthesize title;
@synthesize bitRate;
//@synthesize format;

@end

