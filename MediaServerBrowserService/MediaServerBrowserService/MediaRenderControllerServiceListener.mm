//
//  MediaRenderControllerServiceListener.m
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#include "MediaRenderControllerServiceListener.h"

MediaRenderControllerServiceListener::MediaRenderControllerServiceListener(id serviceDelegate) :
    serviceDelegate_(serviceDelegate)
{
    
}

bool MediaRenderControllerServiceListener::OnMRAdded(PLT_DeviceDataReference &device)
{
    return true;
}

void MediaRenderControllerServiceListener::OnMRRemoved(PLT_DeviceDataReference &device)
{
    
}