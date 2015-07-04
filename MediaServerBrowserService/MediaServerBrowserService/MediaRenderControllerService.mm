//
//  MediaRenderControllerService.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/27.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaRenderControllerService.h"

#include <list>
#include "Platinum/Platinum.h"
#include "upnpdeamon.h"

#define MEDIARENDERADDEDNOTIFICATION @"MediaRenderAddedNotification"
#define MEDIARENDERREMOVEDNOTIFICATION @"MediaRenderRemovedNotification"

class MediaRenderLinster;

@implementation MediaRenderControllerService
{
    NPT_Reference<PLT_MediaController> controller_;
    PLT_CtrlPointReference ctrlPoint_;
    NSMutableDictionary *renderDic_;
    MediaRenderLinster *listener_;
}

+ (instancetype)instance
{
    static MediaRenderControllerService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MediaRenderControllerService alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        renderDic_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)startService
{
    if ( !controller_.IsNull() ) {
        NSLog(@"[MediaRenderControllerService] [startService] services is already start");
        return YES;
    }
    if (ctrlPoint_.IsNull()) {
        ctrlPoint_ = new PLT_CtrlPoint();
    }
    listener_ = new MediaRenderLinster();
    controller_ = new PLT_MediaController(ctrlPoint_, listener_);
    UPnPDeamon::instance()->addCtrlPoint(ctrlPoint_);
    return YES;
}

- (void)stopService
{
    if ( controller_.IsNull()) {
        NSLog(@"[MediaRenderControllerService] [stopService] services isn't start");
        return;
    }
    UPnPDeamon::instance()->removeCtrlPoint(ctrlPoint_);
    [renderDic_ removeAllObjects];
    controller_.Detach();
    delete listener_;
    listener_ = NULL;
}

- (MediaRenderController*)controllerWithUUID:(NSString*)UUID
{
    /*
    MediaRenderController *renderCtr = NULL;
    PLT_DeviceDataReference device;
    NPT_Result res = controller_->FindRenderer([UUID UTF8String], device);
    if ( NPT_SUCCEEDED(res) ) {
        renderCtr = [renderDic_ valueForKey:UUID];
        if (renderCtr == nil) {
            //renderCtr = [[MediaRenderController alloc] init];
            //[renderDic_ setObject:renderCtr forKey:UUID];
        }
    }
    return renderCtr;
     */
    return nil;
}

- (NSDictionary*)renderDic
{
    NSMutableDictionary *renders = [[NSMutableDictionary alloc] init];

    return [renders copy];
}

class MediaRenderLinster : public PLT_MediaControllerDelegate
{
public:
    MediaRenderLinster() {
        
    }
    
    bool OnMRAdded( PLT_DeviceDataReference& device ) {
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
    
    void OnMRRemoved(PLT_DeviceDataReference& device) {
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
    
    NSDictionary* allRender() {
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
    
private:
    std::list<PLT_DeviceDataReference> renders_;
};

@end
