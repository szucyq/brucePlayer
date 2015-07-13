//
//  MediaRenderControllerServiceListener.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#include "MediaRenderControllerServiceListener.h"

#define MEDIARENDERADDEDNOTIFICATION @"MediaRenderAddedNotification"
#define MEDIARENDERREMOVEDNOTIFICATION @"MediaRenderRemovedNotification"

MediaRenderControllerServiceListener::MediaRenderControllerServiceListener()
{

}

bool MediaRenderControllerServiceListener::OnMRAdded(PLT_DeviceDataReference &device)
{
    NSLog(@"[MediaRenderLinster] [OnMRAdded] render add %s", device->GetFriendlyName().GetChars());
    NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
    NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
    
    //call back
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                          forKeys:@[@"UUID", @"FriendlyName"]];
        NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERADDEDNOTIFICATION object:value];
        [[NSNotificationCenter defaultCenter] postNotification:ntf];
    });
    renders_.push_back(device);
    return true;
}

void MediaRenderControllerServiceListener::OnMRRemoved(PLT_DeviceDataReference &device)
{
    NSLog(@"[MediaRenderLinster] [OnMRRemoved] render add %s", device->GetFriendlyName().GetChars());
    NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
    NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
    
    //call back
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                          forKeys:@[@"UUID", @"FriendlyName"]];
        NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERREMOVEDNOTIFICATION object:value];
        [[NSNotificationCenter defaultCenter] postNotification:ntf];
    });
    renders_.remove(device);

}

NSDictionary* MediaRenderControllerServiceListener::allRenders()
{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    std::list<PLT_DeviceDataReference>::iterator iter = renders_.begin();
    while ( iter != renders_.end() ) {
        NSString *UUID = [NSString stringWithUTF8String:(*iter)->GetUUID().GetChars()];
        NSString *friendlyName = [NSString stringWithUTF8String:(*iter)->GetFriendlyName().GetChars()];
        [tmp setObject:friendlyName forKey:UUID];
        iter++;
    }
    return [tmp copy];
}

void MediaRenderControllerServiceListener::OnSetAVTransportURIResult(NPT_Result res, PLT_DeviceDataReference &device, void *userData)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userData);
    void (^callback)(BOOL) = [dic valueForKey:@"setUri"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnGetPositionInfoResult(NPT_Result res
                                                                   , PLT_DeviceDataReference &device
                                                                   , PLT_PositionInfo *info
                                                                   , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL, NSTimeInterval) = [dic valueForKey:@"getCurPos"];
    NSTimeInterval pos = info ? info->abs_time.ToSeconds() : 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO, pos);
    });
}

void MediaRenderControllerServiceListener::OnGetVolumeResult(NPT_Result res
                                                             , PLT_DeviceDataReference &device
                                                             , const char *channel
                                                             , NPT_UInt32 volume
                                                             , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL, NSInteger) = [dic valueForKey:@"getVolume"];
    NSInteger vol = volume;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO, vol);
    });
}

void MediaRenderControllerServiceListener::OnGetMediaInfoResult(NPT_Result res
                                                                , PLT_DeviceDataReference &device
                                                                , PLT_MediaInfo *info
                                                                , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    NSString *key = [[dic allKeys] firstObject];
    if ( [key isEqualToString:@"getCurUri"] ) {
        void (^callback)(BOOL, NSString*) = [dic valueForKey:@"getCurUri"];
        NSString *uri = [NSString stringWithUTF8String: info->cur_uri.GetChars()];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(NPT_SUCCEEDED(res) ? YES : NO, uri);
        });
    }
}

void MediaRenderControllerServiceListener::OnPlayResult(NPT_Result res
                                                        , PLT_DeviceDataReference &device
                                                        , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"play"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnPauseResult(NPT_Result res
                                                         , PLT_DeviceDataReference &device
                                                         , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"pause"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnStopResult(NPT_Result res
                                                         , PLT_DeviceDataReference &device
                                                         , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"stop"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnSeekResult(NPT_Result res
                                                        , PLT_DeviceDataReference &device
                                                        , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"seek"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnSetVolumeResult(NPT_Result res
                                                        , PLT_DeviceDataReference &device
                                                        , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"setVolume"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnSetMuteResult(NPT_Result res
                                                             , PLT_DeviceDataReference &device
                                                             , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"setMute"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnNextResult(NPT_Result res
                                                           , PLT_DeviceDataReference &device
                                                           , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"next"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}

void MediaRenderControllerServiceListener::OnPreviousResult(NPT_Result res
                                                        , PLT_DeviceDataReference &device
                                                        , void *userdata)
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL) = [dic valueForKey:@"previous"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO);
    });
}