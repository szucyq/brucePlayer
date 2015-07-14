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
    NPT_Result result = controller_->SetAVTransportURI(device_, DEFAULT_INSTANCE_ID, [url UTF8String], didl.GetChars(), (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [setUri] failure res = %d", result);
    }
}

- (void)getCurPos:(void (^)(BOOL, NSTimeInterval))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"getCurPos"];
    NPT_Result result = controller_->GetPositionInfo(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [getCurPos] failure res = %d", result);
    }
}

- (void)getCurUri:(void (^)(BOOL, NSString *))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"getCurUri"];
    NPT_Result result = controller_->GetMediaInfo(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [getCurUri] failure res = %d", result);
    }
}

- (void)getVolume:(void (^)(BOOL, NSInteger))handler
{
    const char *channel = "1";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"getVolume"];
    NPT_Result result = controller_->GetVolume(device_, DEFAULT_INSTANCE_ID, channel, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [getVolume] failure res = %d", result);
    }
}

- (void)getStat:(void (^)(BOOL, int))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"getStat"];
    NPT_Result result = controller_->GetTransportInfo(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [getStat] failure res = %d", result);
    }
}

- (void)play:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"play"];
    const char* speed = "1";
    NPT_Result result = controller_->Play(device_, DEFAULT_INSTANCE_ID, speed, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [play] failure res = %d", result);
    }
}

- (void)pause:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"pause"];
    NPT_Result result = controller_->Pause(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [pause] failure res = %d", result);
    }
}

- (void)stop:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"stop"];
    NPT_Result result = controller_->Stop(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [stop] failure res = %d", result);
    }
}

- (void)seek:(NSTimeInterval)pos handler:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"seek"];
    NPT_String posStr( (NPT_TimeStamp(pos)) );
    const char *target = "0";
    NPT_Result result = controller_->Seek(device_, DEFAULT_INSTANCE_ID, posStr.GetChars(), target, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [seek] failure res = %d", result);
    }
}

- (void)setVolume:(int)vol handler:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"setVolume"];
    const char *channel = "1";
    NPT_Result result = controller_->SetVolume(device_, DEFAULT_INSTANCE_ID, channel, vol, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [setVolume] failure res = %d", result);
    }
}

- (void)setMute:(BOOL)isMute handler:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"setMute"];
    const char *channel = "Master";
    NPT_Result result = controller_->SetMute(device_, DEFAULT_INSTANCE_ID, channel, isMute!=YES ? true : false, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [setMute] failure res = %d", result);
    }
}

- (void)next:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"next"];
    NPT_Result result = controller_->Next(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [next] failure res = %d", result);
    }
}

- (void)previous:(void (^)(BOOL))handler
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:handler forKey:@"previous"];
    NPT_Result result = controller_->Previous(device_, DEFAULT_INSTANCE_ID, (void*)CFBridgingRetain(dic));
    if ( NPT_FAILED(result) ) {
        NSLog(@"[MediaRenderControllerImpl] [previous] failure res = %d", result);
    }
}

@end

@implementation MediaRenderController

@end