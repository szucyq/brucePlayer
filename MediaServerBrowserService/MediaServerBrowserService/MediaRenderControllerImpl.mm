//
//  MediaRenderControllerImpl.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaRenderControllerImpl.h"

#define DEFAULT_INSTANCE_ID 0

@implementation MediaRenderControllerImpl
{
    NPT_Reference<PLT_MediaController> controller_;
    id delegate_;
    PLT_DeviceDataReference device_;
}

@synthesize UUID = UUID_;

- (id)initWithController:(PLT_MediaController *)controller
                    UUID:(NSString *)UUID
                delegate:(id)delegate
{
    self = [super init];
    if (self) {
        controller_ = controller;
        UUID_ = UUID;
        delegate_ = delegate;
        NPT_Result ret = controller_->FindRenderer([UUID_ UTF8String], device_);
        if ( NPT_FAILED(ret) ) {
            NSLog(@"[MediaRenderControllerImpl] [initWithController] failure!!!");
        }
    }
    return self;
}

- (NSString*)friendlyName
{
    return [NSString stringWithUTF8String:device_->GetFriendlyName().GetChars()];
}

- (void)getCurPos:(void *)userData
{
    controller_->GetPositionInfo(device_, DEFAULT_INSTANCE_ID, userData);
}

- (void)getCurUri:(void *)userData
{
    
}

- (void)getVolume:(void *)userData
{
    const char *channel = "1";
    controller_->GetVolume(device_, DEFAULT_INSTANCE_ID, channel, userData);
}

- (void)getStat:(void *)userData
{
    
}

@end

@implementation MediaRenderController

@end