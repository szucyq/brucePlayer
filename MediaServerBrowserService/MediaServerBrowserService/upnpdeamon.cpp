//
//  upnpdeamon.cpp
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/26.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#include "upnpdeamon.h"

UPnPDeamon* UPnPDeamon::instance_ = NULL;

UPnPDeamon* UPnPDeamon::instance()
{
    if (instance_ == NULL) {
        instance_ = new UPnPDeamon();
    }
    return instance_;
}

int UPnPDeamon::addDevice(PLT_DeviceHostReference &dev)
{
    NPT_Result ret = upnp_.AddDevice(dev);
    if (NPT_SUCCEEDED(ret)) {
        PDCounter_++;
        updateDeamon();
        return 0;
    }
    return -1;
}

int UPnPDeamon::removeDevice(PLT_DeviceHostReference &dev)
{
    NPT_Result ret = upnp_.RemoveDevice(dev);
    if (NPT_SUCCEEDED(ret)) {
        PDCounter_--;
        updateDeamon();
        return 0;
    }
    return -1;
}

int UPnPDeamon::addCtrlPoint(PLT_CtrlPointReference &ctrlPoint)
{
    NPT_Result ret = upnp_.AddCtrlPoint(ctrlPoint);
    if (NPT_SUCCEEDED(ret)) {
        PDCounter_++;
        updateDeamon();
        return 0;
    }
    return -1;
}

int UPnPDeamon::removeCtrlPoint(PLT_CtrlPointReference &ctrlPoint)
{
    NPT_Result ret = upnp_.RemoveCtrlPoint(ctrlPoint);
    if (NPT_SUCCEEDED(ret)) {
        PDCounter_--;
        updateDeamon();
        return 0;
    }
    return -1;
}

void UPnPDeamon::updateDeamon()
{
    if (PDCounter_ == 0) {
        upnp_.Stop();
    } else if (PDCounter_ == 1
               && !upnp_.IsRunning()) {
        upnp_.Start();
    }
}