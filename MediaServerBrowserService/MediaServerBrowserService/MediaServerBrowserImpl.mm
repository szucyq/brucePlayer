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

- (id)initWithDevice:(PLT_DeviceDataReference)device
            controller:(PLT_MediaBrowser*)controller
{
    self = [super init];
    if (self) {
        device_ = device;
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

- (void)browseRoot:(void (^)(BOOL ret, NSString* objID, NSArray*items))handler
{
    [self browse:@"0" handler:handler];
}

- (void)browse:(NSString *)objID
       handler:(void (^)(BOOL, NSString *, NSArray *))handler
{
    NPT_UInt32 start_index = 0;
    NPT_UInt32 count = 30;
    bool browse_metadata = false;
    const char* filter = "dc:date,upnp:genre,res,res@duration,res@size,upnp:albumArtURI,upnp:originalTrackNumber,upnp:album,upnp:artist,upnp:author";
    const char* sort_criteria = "";
    browserController_->Browse(device_, [objID UTF8String], start_index, count, browse_metadata, filter,sort_criteria, (void*)handler);
}
@end

/*************************************************************/
@implementation MediaServerBrowser

@end