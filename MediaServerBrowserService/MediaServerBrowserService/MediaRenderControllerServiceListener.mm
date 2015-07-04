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
        [tmp setObject:UUID forKey:@"UUID"];
        NSString *friendlyName = [NSString stringWithUTF8String:(*iter)->GetFriendlyName().GetChars()];
        [tmp setObject:friendlyName forKey:@"FriendlyName"];
        iter++;
    }
    return [tmp copy];
}