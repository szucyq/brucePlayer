//
//  MediaServerBrowserService.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/24.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerBrowserService.h"
#import "MediaServerBrowserImpl.h"
#include <list>

#include "Platinum/Platinum.h"

#include "upnpdeamon.h"

#define MEDIASERVERADDEDNOTIFICATION @"MediaServerAddedNotification"
#define MEDIASERVERMOVEDNOTIFICATION @"MediaServerRemovedNotification"

class MediaServerListener;

@implementation MediaServerItem

@synthesize objID;
@synthesize title;
@synthesize uri;
@synthesize size;
@synthesize duration;
@synthesize bitrate;
@synthesize type;
@synthesize artist;
@synthesize date;
@synthesize composer;
@synthesize trackList;
@synthesize codeType;
@synthesize contentFormat;
@synthesize mimeType;
@synthesize extention;
@synthesize albumArtURI;
@synthesize iconURI;
@synthesize album;
@synthesize genres;

@end

@implementation MediaServerBrowserService
{
    NPT_Reference<PLT_MediaBrowser> browser_;
    PLT_CtrlPointReference ref_;
    MediaServerListener *listener_;
    NSMutableDictionary *browserDic_;
}

//double MediaServerBrowserServiceVersionNumber = 2.0;
//const unsigned char MediaServerBrowserServiceVersionString[] = "2.0";

- (id)init
{
    self = [super init];
    if (self) {
        browser_ = NULL;
        listener_ = NULL;
        browserDic_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)isRunning
{
    return browser_.IsNull() ? NO : YES;
}

+ (instancetype)instance
{
    static MediaServerBrowserService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MediaServerBrowserService alloc] init];
    });
    return instance;
}

- (BOOL)startService
{
    if ( self.isRunning ) {
        NSLog(@"[MediaServerBrowserService] [startService] DMS-C already start!");
        return YES;
    }
    ref_ = new PLT_CtrlPoint();
    listener_ = new MediaServerListener();
    browser_ = new PLT_MediaBrowser(ref_, listener_);
    UPnPDeamon::instance()->addCtrlPoint(ref_);
    NSLog(@"[MediaServerBrowserService] [startService] success");
    return YES;
}

- (void)stopService
{
    if ( !self.isRunning ) {
        NSLog(@"[MediaServerBrowserService] [stopService] DMS-C not start!");
        return;
    }
    UPnPDeamon::instance()->removeCtrlPoint(ref_);
    [browserDic_ removeAllObjects];
    browser_.Detach();
    ref_.Detach();
    delete listener_;
    listener_ = NULL;
    NSLog(@"[MediaServerBrowserService] [stopService] success!");
}

- (MediaServerBrowser*)browserWithUUID:(NSString *)uuid
{
    NSLog(@"[MediaServerBrowserService] [browserWithUUID] uuid = %@", uuid);
    MediaServerBrowser* browser = [browserDic_ valueForKey:uuid];
    if (!browser) {
        PLT_DeviceDataReference device = listener_->device([uuid UTF8String]);
        browser = [[MediaServerBrowserImpl alloc] initWithDevice:device controller:browser_.AsPointer()];
        [browserDic_ setObject:browser forKey:uuid];
    } 
    return browser;
}

- (MediaServerBrowser*)findBrowser:(NSString *)uuid
{
    return [browserDic_ valueForKey:uuid];
}

- (NSDictionary*)mediaServer
{
    return listener_->allDevice();
}

class MediaServerListener : public PLT_MediaBrowserDelegate
{
public:
    MediaServerListener()
    {
        
    }
    
    bool OnMSAdded(PLT_DeviceDataReference& device ) {
        NSLog(@"[OnMSAdded] ms add %s", device->GetFriendlyName().GetChars());
        devices_.push_back(device);
        NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
        NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
        
        //call back
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                              forKeys:@[@"UUID", @"FriendlyName"]];
            NSNotification *ntf = [NSNotification notificationWithName:MEDIASERVERADDEDNOTIFICATION object:value];
            [[NSNotificationCenter defaultCenter] postNotification:ntf];
        });
        return true;
    }
    
    void OnMSRemoved(PLT_DeviceDataReference& device ) {
        NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
        NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *value = [NSDictionary dictionaryWithObjects:@[uuid,friendlyName]
                                                              forKeys:@[@"UUID", @"FriendlyName"]];
            NSNotification *ntf = [NSNotification notificationWithName:MEDIASERVERMOVEDNOTIFICATION
                                                                object:value];
            [[NSNotificationCenter defaultCenter] postNotification:ntf];
        });
        devices_.remove(device);
    }
    
    void fileItem(PLT_MediaObject *obj, MediaServerItem *item)
    {
        if ( obj->m_ObjectClass.type.StartsWith("object.container") ) {
            item.type = FOLDER;
        } else if ( obj->m_ObjectClass.type.StartsWith("object.item.videoItem") ) {
            item.type = VIDEO;
        } else if ( obj->m_ObjectClass.type.StartsWith("object.item.audioItem") ) {
            item.type = AUDIO;
        } else if ( obj->m_ObjectClass.type.StartsWith("object.item.imageItem") ) {
            item.type = IMAGE;
        } else {
            item.type = UNKNOW;
        }
    
        item.objID = [NSString stringWithUTF8String:obj->m_ObjectID.GetChars()];
        item.iconURI = [NSString stringWithUTF8String:obj->m_Description.icon_uri.GetChars()];
        item.title = [NSString stringWithUTF8String:obj->m_Title.GetChars()];
        item.date = [NSString stringWithUTF8String:obj->m_Date.GetChars()];
        item.album = [NSString stringWithUTF8String:obj->m_Affiliation.album.GetChars()];
        NSMutableArray *genresArray = [[NSMutableArray alloc] init];
        for( NPT_Cardinal i=0; i<obj->m_Affiliation.genres.GetItemCount(); i++) {
            [genresArray addObject:[NSString stringWithUTF8String:obj->m_Affiliation.genres.GetItem(i)->GetChars()]];
        }
        item.genres = [genresArray copy];
        if ( obj->m_Resources.GetItemCount() > 0 ) {
            PLT_MediaItemResource *mr = obj->m_Resources.GetItem(0);
//            for(NPT_Cardinal i=0; i<obj->m_Resources.GetItemCount(); i++) {
//                mr = obj->m_Resources.GetItem(i);
//                if ( mr->m_Duration > 0 ) {
//                    break;
//                }
//            }
            item.uri = [NSString stringWithUTF8String:
                        mr->m_Uri.GetChars()];
            item.size = mr->m_Size;
            item.duration = mr->m_Duration;
            item.bitrate = mr->m_Bitrate;
            NPT_String extra = mr->m_ProtocolInfo.GetDLNA_PN();
            NPT_String mimeType = PLT_ProtocolInfo::GetMimeTypeFromProtocolInfo(mr->m_ProtocolInfo.ToString());
            mimeType = *(mimeType.Split("/").GetFirstItem());
            item.extention = [NSString stringWithUTF8String:mr->m_ProtocolInfo.GetDLNA_PN().GetChars()];
        }//obj->m_Date.GetChars();
    };

    void OnBrowseResult( NPT_Result res
                        , PLT_DeviceDataReference& device
                        , PLT_BrowseInfo* info
                        , void* userData) {
        //get callback method
        NSLog(@"[OnBrowseResult] res = %d, item count = %d"
              , res
              , res == 0 ? info->items->GetItemCount() : 0);
        //NSString *uuid = [NSString stringWithUTF8String:device->GetUUID().GetChars()];
        NSMutableArray *tmp = nil;
        NSString *path = nil;
        if (NPT_SUCCEEDED(res)) {
            //
            tmp = [[NSMutableArray alloc] init];
            if ( info->items->GetItemCount() > 0 ) {
                PLT_MediaObjectList::Iterator iter = info->items->GetFirstItem();
                while ( iter ) {
                    MediaServerItem *item = [[MediaServerItem alloc] init];
                    fileItem(*iter, item);
                    [tmp addObject:item];
                    iter++;
                }
            }
            
            path = [NSString stringWithUTF8String:info->object_id.GetChars()];
        }
        NSArray *items = tmp == nil ? nil : [tmp copy];
        
        NSMutableDictionary *dic = (NSMutableDictionary*)CFBridgingRelease(userData);//
        //NSString *key = [NSString stringWithUTF8String:info->object_id.GetChars()];
        
        void (^callback)(BOOL ret, NSString* objID, NSArray* items) = [dic valueForKey:@"browse"];
        dispatch_async( dispatch_get_main_queue(), ^{
            callback(res==0, path, items);
        });

    }
    
    PLT_DeviceDataReference device(const char *uuid) {
        PLT_DeviceDataReference device;
        std::list<PLT_DeviceDataReference>::iterator iter = devices_.begin();
        while ( iter != devices_.end() ) {
            if ((*iter)->GetUUID() == uuid) {
                device = *iter;
                break;
            }
            iter++;
        }
        return device;
    }
    
    NSDictionary* allDevice() {
        NSMutableDictionary *devs = [[NSMutableDictionary alloc] init];
        std::list<PLT_DeviceDataReference>::iterator iter = devices_.begin();
        while ( iter != devices_.end() ) {
            NSString *UUID = [NSString stringWithUTF8String:(*iter)->GetUUID().GetChars()];
            //[devs setObject:UUID forKey:@"UUID"];
            NSString *friendlyName = [NSString stringWithUTF8String:(*iter)->GetFriendlyName().GetChars()];
            //[devs setObject:friendlyName forKey:@"FriendlyName"];
            [devs setObject:UUID forKey:friendlyName];
            iter++;
        }
        return [devs copy];
    }
private:
    MediaServerBrowserService* service_;
    std::list<PLT_DeviceDataReference> devices_;
};
@end
