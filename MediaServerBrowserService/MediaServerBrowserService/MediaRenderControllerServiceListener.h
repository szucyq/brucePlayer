//
//  MediaRenderControllerServiceListener.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#ifndef MEDIARENDERCONTROLLERSERVICELISTENER_H
#define MEDIARENDERCONTROLLERSERVICELISTENER_H

#include "Platinum/Platinum.h"
#include <list>
#import <Foundation/Foundation.h>

class MediaRenderControllerServiceListener : public PLT_MediaControllerDelegate
{
public:
    MediaRenderControllerServiceListener();
    
    bool OnMRAdded(PLT_DeviceDataReference& device);
    void OnMRRemoved(PLT_DeviceDataReference& device);
    
    NSDictionary* allRenders();
    
private:
    std::list<PLT_DeviceDataReference> renders_;
};

#endif