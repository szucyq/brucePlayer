//
//  MediaServerBrowserImpl.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerBrowserImpl.h"

@implementation MediaServerBrowserImpl
{
    PLT_DeviceDataReference device_;
    NPT_Reference<PLT_MediaBrowser> browserController_;
}

@synthesize delegate = delegate_;

- (id)initWithDelegate:(id)delegate
                device:(PLT_DeviceDataReference)device
            controller:(PLT_MediaBrowser*)controller
{
    self = [super init];
    if (self) {
        device_ = device;
        delegate_ = delegate;
        browserController_ = controller;
    }
    return self;
}

- (NSString*)uuid
{
    NSString *uuid = [NSString stringWithUTF8String:device_->GetUUID().GetChars()];
    return uuid;
}

- (NSString*)friendlyName
{
    NSString *friendlyName = [NSString stringWithUTF8String:device_->GetFriendlyName().GetChars()];
    return friendlyName;
}

- (void)browseRoot
{
    const char objectID[] = "0";
    int index = 0;
    browserController_->Browse(device_, objectID, index);
}

- (void)browse:(NSString *)path
{
    int index = 0;
    browserController_->Browse(device_, [path UTF8String], index);
}
@end

/*************************************************************/
@implementation MediaServerBrowser

@end