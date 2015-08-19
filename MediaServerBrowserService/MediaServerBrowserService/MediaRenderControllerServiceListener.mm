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
#define MEDIARENDERSTATENOTIFICATION @"MediaRenderStateNotification"
#define MEDIARENDERDURATIONNOTIFICATION @"MediaRenderDurationNotification"
#define MEDIARENDERTITLENOTIFICATION @"MediaRenderTitleNotification"

MediaRenderControllerServiceListener::MediaRenderControllerServiceListener()
{

}

bool MediaRenderControllerServiceListener::OnMRAdded(PLT_DeviceDataReference &device)
{
    NSLog(@"[MediaRenderListener] [OnMRAdded] render add %s", device->GetFriendlyName().GetChars());
    renders_.push_back(device);
    NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
    NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
    
    //call back
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                          forKeys:@[@"UUID", @"FriendlyName"]];
        NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERADDEDNOTIFICATION object:value];
        [[NSNotificationCenter defaultCenter] postNotification:ntf];
    });
    return true;
}

void MediaRenderControllerServiceListener::OnMRRemoved(PLT_DeviceDataReference &device)
{
    NSLog(@"[MediaRenderListener] [OnMRRemoved] render add %s", device->GetFriendlyName().GetChars());
    renders_.remove(device);
    NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
    NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
    
    //call back
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                          forKeys:@[@"UUID", @"FriendlyName"]];
        NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERREMOVEDNOTIFICATION object:value];
        [[NSNotificationCenter defaultCenter] postNotification:ntf];
    });
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
        itemInfo.nextUrl = [NSString stringWithUTF8String: info->next_uri];
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
    if ( NPT_FAILED(res) ) {
        callback(NO, 0);
    }
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
        callback(YES, st);
    });
}

void MediaRenderControllerServiceListener::OnMRStateVariablesChanged(PLT_Service *service
                               , NPT_List<PLT_StateVariable*> *vars)
{
    //service->GetDevice()->GetUUID();
    NPT_List<PLT_StateVariable*>::Iterator iter = vars->GetFirstItem();
    while ( iter ) {
        NSString *UUID = [NSString stringWithUTF8String:service->GetDevice()->GetUUID().GetChars()];
        NPT_String stateName = (*iter)->GetName();
        if ( stateName == "TransportState" ) {
            RenderStatu st = RenderStatu::STAT_UNKNOW;
            NPT_String value = (*iter)->GetValue().ToLowercase();
            if ( value == "stopped" ) {
                st = RenderStatu::STOPED;
            } else if ( value == "paused_playback" ) {
                st = RenderStatu::PAUSED;
            } else if ( value == "playing" ) {
                st = RenderStatu::PLAYING;
            } else if ( value == "transitioning" ) {
                st = RenderStatu::LOADING;
            } else if ( value == "no_media_present" ) {
                st = RenderStatu::STOPED;
            }
            NSNumber *state = [NSNumber numberWithInt:st];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[UUID, state]
                                                              forKeys:@[@"UUID", @"state"]];
            NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERSTATENOTIFICATION object:dic];
            [[NSNotificationCenter defaultCenter] postNotification:ntf];
        } else if ( stateName == "CurrentTrackDuration") {
            NPT_List<NPT_String> ts = (*iter)->GetValue().Split(":");
            int h = 0;
            int m = 0;
            int s = 0;
            if (ts.GetItemCount() == 3) {
                ts.GetItem(0)->ToInteger(h);
                ts.GetItem(1)->ToInteger(m);
                ts.GetItem(2)->ToInteger(s);
            }
            NSNumber *sconds = [NSNumber numberWithInt:h*3600 + m*60 + s];
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[UUID, sconds]
                                                            forKeys:@[@"UUID", @"duration"]];
            NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERDURATIONNOTIFICATION object:dic];
            [[NSNotificationCenter defaultCenter] postNotification:ntf];
        } else if ( stateName == "CurrentTrackMetaData") {
            PLT_MediaObjectListReference objs(new PLT_MediaObjectList());
            NPT_String value = (*iter)->GetValue();
            NSString *title = [[NSString alloc] init];
            if (NPT_SUCCEEDED(PLT_Didl::FromDidl(value, objs))) {
                if (objs->GetItemCount() >= 1) {
                    PLT_MediaItem *p = dynamic_cast<PLT_MediaItem*>(*(objs->GetFirstItem()));
                    title = [NSString stringWithUTF8String:p->m_Title.GetChars()];
                }
            }
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[UUID, title]
                                                            forKeys:@[@"UUID", @"title"]];
            NSNotification *ntf = [NSNotification notificationWithName:MEDIARENDERTITLENOTIFICATION object:dic];
            [[NSNotificationCenter defaultCenter] postNotification:ntf];
        }
        //NSLog(@"%s  %s", (*iter)->GetName().GetChars(), (*iter)->GetValue().GetChars());
        iter++;
    }
    return PLT_MediaControllerDelegate::OnMRStateVariablesChanged(service, vars);
}