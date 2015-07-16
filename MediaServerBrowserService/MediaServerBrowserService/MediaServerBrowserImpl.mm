//
//  MediaServerBrowserImpl.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerBrowserImpl.h"

@interface MediaServerBrowserImpl()

@property (nonatomic) NSMutableDictionary *blockDic;

@end


@implementation MediaServerBrowserImpl
{
    PLT_DeviceDataReference device_;
    NPT_Reference<PLT_MediaBrowser> browserController_;
}

@synthesize blockDic = blockDic_;

- (id)initWithDevice:(PLT_DeviceDataReference)device
            controller:(PLT_MediaBrowser*)controller
{
    self = [super init];
    if (self) {
        device_ = device;
        browserController_ = controller;
        blockDic_ = [[NSMutableDictionary alloc] init];
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

- (NSString*)IP
{
    NSString *IPStr = [NSString stringWithUTF8String:device_->GetLocalIP().ToString().GetChars()];
    return IPStr;
}

- (NSString*)iconUrl
{
    NSString *url = [NSString stringWithUTF8String:device_->GetIconUrl().GetChars()];
    return url;
}

- (void)browseRoot:(void (^)(BOOL ret, NSString* objID, NSArray*items))handler
{
    [self browse:@"0" handler:handler];
}

- (void)browse:(NSString *)objID
       handler:(void (^)(BOOL, NSString *, NSArray *))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"browse"];

    NPT_UInt32 start_index = 0;
    NPT_UInt32 count = 30;
    bool browse_metadata = false;
    const char* filter = "dc:date,upnp:genre,res,res@duration,res@size,upnp:albumArtURI,upnp:originalTrackNumber,upnp:album,upnp:artist,upnp:author";
    const char* sort_criteria = "";
    
    //
    browserController_->Browse(device_, [objID UTF8String], start_index, count, browse_metadata, filter,sort_criteria, (void*)CFBridgingRetain(dic));
}
@end

/*************************************************************/
@implementation MediaServerBrowser

@end