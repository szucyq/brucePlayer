//
//  upnpdeamon.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/26.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#ifndef MediaServerBrowserService_upnpdeamon_h
#define MediaServerBrowserService_upnpdeamon_h

#include "Platinum/Platinum.h"

class UPnPDeamon
{
public:
    static UPnPDeamon* instance();
    
    int addDevice(PLT_DeviceHostReference &dev);
    
    int removeDevice(PLT_DeviceHostReference &dev);
    
    int addCtrlPoint(PLT_CtrlPointReference &ctrlPoint);
    
    int removeCtrlPoint(PLT_CtrlPointReference &ctrlPoint);
    
    
private:
    UPnPDeamon() :
        PDCounter_(0) {}
    
    void updateDeamon();
    
private:
    static UPnPDeamon* instance_;
    PLT_UPnP upnp_;
    int PDCounter_;
};

#endif
