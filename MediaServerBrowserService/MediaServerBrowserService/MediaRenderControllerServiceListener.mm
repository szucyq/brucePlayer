//
//  MediaRenderControllerServiceListener.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#include "MediaRenderControllerServiceListener.h"

#include "MediaRenderControllerService.h"

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
    void (^callback)(BOOL, NSTimeInterval, NSTimeInterval) = [dic valueForKey:@"getCurPos"];
    //
    NSTimeInterval pos = info ? info->rel_time.ToSeconds() : 0;
    NSTimeInterval duration = info ? info->track_duration.ToSeconds() : 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO, pos, duration);
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
        if ( NPT_FAILED(res) ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(NO, nil);
            });
            return;
        }
        NSString *uri = [NSString stringWithUTF8String: info->cur_uri.GetChars()];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES, uri);
        });
    } else if ( [key isEqualToString:@"getMediaInfo"] ) {
        void (^callback)(BOOL, MediaItemInfo*) = [dic valueForKey:@"getMediaInfo"];
        if ( NPT_FAILED(res) ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(NO, nil);
            });
            return;
        }
        MediaItemInfo *itemInfo = [[MediaItemInfo alloc] init];
        itemInfo.duration = info->media_duration.ToSeconds();

        itemInfo.curUrl = [NSString stringWithUTF8String: info->cur_uri.GetChars()];
        //
        PLT_MediaObjectListReference objs(new PLT_MediaObjectList());
        if (NPT_SUCCEEDED(PLT_Didl::FromDidl(info->cur_metadata, objs))) {
            if (objs->GetItemCount() >= 1) {
                PLT_MediaItem *p = dynamic_cast<PLT_MediaItem*>(*(objs->GetFirstItem()));
                itemInfo.title = [NSString stringWithUTF8String:p->m_Title.GetChars()];
                itemInfo.iconUri = [NSString stringWithUTF8String:p->m_Description.icon_uri.GetChars()];
                if ( p->m_Resources.GetItemCount() > 0 ) {
                    itemInfo.bitRate = p->m_Resources.GetFirstItem()->m_Bitrate;
                    itemInfo.extention = [NSString stringWithUTF8String:p->m_Resources.GetFirstItem()->m_ProtocolInfo.GetMimeTypeFromProtocolInfo("audio/mpeg").GetChars()];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES, itemInfo);
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

void MediaRenderControllerServiceListener::OnGetTransportInfoResult(NPT_Result res
                                                                    , PLT_DeviceDataReference& device
                                                                    , PLT_TransportInfo* info
                                                                    , void* userdata )
{
    NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userdata);
    void (^callback)(BOOL,int) = [dic valueForKey:@"getStat"];
    NSString *stStr = [NSString stringWithUTF8String:info->cur_transport_state.GetChars()];
    int st = 4; //unknow
    stStr = [stStr lowercaseString];
    if ( [stStr isEqualToString:@"stopped"] ) {
        st = 0;
    } else if ( [stStr isEqualToString:@"paused_playback"] ) {
        st = 2;
    } else if ( [stStr isEqualToString:@"playing"] ) {
        st = 1;
    } else if ( [stStr isEqualToString:@"transitioning"] ) {
        st = 3;
    } else if ( [stStr isEqualToString:@"no_media_present"] ) {
        st = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(NPT_SUCCEEDED(res) ? YES : NO, st);
    });
}