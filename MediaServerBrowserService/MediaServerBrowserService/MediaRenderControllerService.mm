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

@implementation MediaRenderControllerService
{
    PLT_MediaController *controller_;
    PLT_CtrlPointReference ctrlPoint_;
    id delegate_;
}

+ (id)instance
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
        controller_ = NULL;
    }
    return self;
}

- (BOOL)startService:(id)delegate
{
    if (controller_) {
        NSLog(@"[MediaRenderControllerService] [startService] services is already start");
        return YES;
    }
    delegate_ = delegate;
    if (ctrlPoint_.IsNull()) {
        ctrlPoint_ = new PLT_CtrlPoint();
    }
    controller_ = new PLT_MediaController(ctrlPoint_);
    UPnPDeamon::instance()->addCtrlPoint(ctrlPoint_);
    return YES;
}

- (void)stopService
{
    if (controller_ == NULL) {
        NSLog(@"[MediaRenderControllerService] [stopService] services isn't start");
        return;
    }
    UPnPDeamon::instance()->removeCtrlPoint(ctrlPoint_);
    delete controller_;
    controller_ = NULL;
}

- (MediaRenderController*)controllerWithUUID:(NSString*)UUID
{
    MediaRenderController *renderCtr = NULL;
    PLT_DeviceDataReference device;
    NPT_Result res = controller_->FindRenderer([UUID UTF8String], device);
    if ( NPT_SUCCEEDED(res) ) {
        
    }
    return renderCtr;
}

@end
