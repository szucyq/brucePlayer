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

class MediaRenderControllerServiceListener : public PLT_MediaControllerDelegate
{
public:
    MediaRenderControllerServiceListener(id serviceDelegate);
    
    bool OnMRAdded(PLT_DeviceDataReference& device);
    void OnMRRemoved(PLT_DeviceDataReference& device);
    
private:
    id serviceDelegate_;
};

#endif