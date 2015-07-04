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
    PLT_DeviceDataReference device_;
}

@synthesize UUID = UUID_;

- (id)initWithController:(PLT_DeviceDataReference)device
              controller:(PLT_MediaController *)controller
{
    self = [super init];
    if (self) {
        controller_ = controller;
        device_ = device;
    }
    return self;
}

- (NSString*)friendlyName
{
    return [NSString stringWithUTF8String:device_->GetFriendlyName().GetChars()];
}

- (void)setUri:(NSString *)url
          name:(NSString *)name
       handler:(void (^)(BOOL))handler
{
    PLT_MediaObjectListReference objs(new PLT_MediaObjectList());
    //create && fill PLT_MediaItem
    PLT_MediaItem item;
    item.m_Title = [name UTF8String];
    item.m_ObjectID = "0";
    item.m_ParentID = "0";
    item.m_Restricted = false;
    item.m_Creator = "pptv";
    //create && fill PLT_MediaItemResource
    PLT_MediaItemResource res;
    res.m_Size = 0;
    NPT_Array<PLT_MediaItemResource> resArr;
    resArr.Add(res);
    item.m_Resources = resArr;
    PLT_ObjectClass objCls;
    objCls.type = "object.item.videoItem";
    item.m_ObjectClass = objCls;
    const char* didl_header =
        "<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0 DIDL-Lite/\""
        " xmlns:dc=\"http://purl.org/dc/elements/1.1/\""
        " xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\""
        " xmlns:dlna=\"urn:schemas-dlna-org:metadata-1-0/\">";
    const char* didl_footer = "</DIDL-Lite>";
    NPT_String didl = didl_header;
    NPT_String tmp;
    item.ToDidl("", tmp);
    didl += tmp;
    didl += didl_footer;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"setUri"];
    controller_->SetAVTransportURI(device_, DEFAULT_INSTANCE_ID, [url UTF8String], didl.GetChars(), (void*)CFBridgingRetain(dic));
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