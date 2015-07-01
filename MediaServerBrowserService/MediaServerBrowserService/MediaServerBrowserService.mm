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

class MediaServerListener;

@implementation MediaServerItem

@synthesize objID;
@synthesize title;
@synthesize uri;
@synthesize size;
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
@synthesize thumbnailUrl;
@synthesize smallImageUrl;
@synthesize mediumImageUrl;
@synthesize largeImageUrl;

@end
@implementation MediaServerBrowserService
{
    PLT_MediaBrowser *browser_;
    PLT_CtrlPointReference ref_;
    MediaServerListener *listener_;
    NSMutableDictionary *browserDic_;
}

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

+ (id)instance
{
    static MediaServerBrowserService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MediaServerBrowserService alloc] init];
    });
    return instance;
}

- (BOOL)startService:(id)delegate
{
    if (browser_ != NULL) {
        NSLog(@"[MediaServerBrowserService] [startService] DMS-C already start!");
        return YES;
    }
    ref_ = new PLT_CtrlPoint();
    listener_ = new MediaServerListener(self, delegate);
    browser_ = new PLT_MediaBrowser(ref_, listener_);
    UPnPDeamon::instance()->addCtrlPoint(ref_);
    NSLog(@"[MediaServerBrowserService] [startService] success");
    return YES;
}

- (void)stopService
{
    if (browser_ == NULL) {
        NSLog(@"[MediaServerBrowserService] [stopService] DMS-C not start!");
        return;
    }
    UPnPDeamon::instance()->removeCtrlPoint(ref_);
    delete browser_;
    browser_ = NULL;
    ref_ = NULL;
    delete listener_;
    listener_ = NULL;
    [browserDic_ removeAllObjects];
    NSLog(@"[MediaServerBrowserService] [stopService] success!");
}

- (MediaServerBrowser*)browserWithUUID:(NSString *)uuid delegate:(id)delegate
{
    NSLog(@"[MediaServerBrowserService] [browserWithUUID] uuid = %@", uuid);
    MediaServerBrowser* browser = [browserDic_ valueForKey:uuid];
    if (!browser) {
        PLT_DeviceDataReference device = listener_->device([uuid UTF8String]);
        browser = [[MediaServerBrowserImpl alloc] initWithDelegate:delegate
                                                            device:device
                                                        controller:browser_];
        [browserDic_ setObject:browser forKey:uuid];
    } 
    return browser;
}

- (MediaServerBrowser*)findBrowser:(NSString *)uuid
{
    return [browserDic_ valueForKey:uuid];
}

- (void)destroyBrowser:(MediaServerBrowser*)browser
{
    [browserDic_ removeObjectForKey:[browser UUID]];
}

class MediaServerListener : public PLT_MediaBrowserDelegate
{
public:
    MediaServerListener(MediaServerBrowserService* service, id delegate) :
        service_(service)
        , delegate_(delegate)
    {
        
    }
    
    bool OnMSAdded(PLT_DeviceDataReference& device ) {
        NSLog(@"[OnMSAdded] ms add %s", device->GetFriendlyName().GetChars());
        devices_.push_back(device);
        __block BOOL isAdd = NO;
        NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
        NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
        //call back
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate_ respondsToSelector:@selector(onMediaServerBrowserAdded:uuid:)]) {
                isAdd = [delegate_ onMediaServerBrowserAdded:friendlyName uuid:uuid];
            }
            if (!isAdd) {
                devices_.remove(device);
            }
        });
        return (isAdd == YES) ? true : false;
    }
    
    void OnMSRemoved(PLT_DeviceDataReference& device ) {
        NSString *friendlyName = [NSString stringWithUTF8String: device->GetFriendlyName().GetChars()];
        NSString *uuid = [NSString stringWithUTF8String: device->GetUUID().GetChars()];
        if ([delegate_ respondsToSelector:@selector(onMediaServerBrowserRemoved:uuid:)]) {
            [delegate_ onMediaServerBrowserRemoved:friendlyName uuid:uuid];
        }
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
        
        item.title = [NSString stringWithUTF8String:obj->m_Title.GetChars()];
        
        if ( obj->m_Resources.GetItemCount() > 0 ) {
            item.uri = [NSString stringWithUTF8String:
                        obj->m_Resources.GetFirstItem()->m_Uri.GetChars()];
            item.size = obj->m_Resources.GetFirstItem()->m_Size;
        }
        obj->m_Date.GetChars();
        

    };

    void OnBrowseResult( NPT_Result res
                        , PLT_DeviceDataReference& device
                        , PLT_BrowseInfo* info
                        , void* userData) {
        //get callback method
        NSLog(@"[OnBrowseResult] res = %d, item count = %d"
              , res
              , res == 0 ? info->items->GetItemCount() : 0);
        NSString *uuid = [NSString stringWithUTF8String:device->GetUUID().GetChars()];
        id delegate;
        if ([service_ findBrowser:uuid] != nil) {
            delegate = [service_ findBrowser:uuid].delegate;
        }
        //
        int ret = res;
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
        
        //
        if ([delegate respondsToSelector:@selector(onBrowseResult:path:items:)]) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [delegate onBrowseResult:ret path:path items:items];
            });
        }
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
    
private:
    id<MediaServerBrowserServiceDelegate> delegate_;
    MediaServerBrowserService* service_;
    std::list<PLT_DeviceDataReference> devices_;
};
@end
