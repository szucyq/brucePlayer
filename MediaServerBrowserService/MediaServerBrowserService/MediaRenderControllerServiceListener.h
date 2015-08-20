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
    
    void OnSetAVTransportURIResult( NPT_Result res
                                   , PLT_DeviceDataReference& device
                                   , void* userdata );
    
    void OnGetPositionInfoResult( NPT_Result res
                                 , PLT_DeviceDataReference& device
                                 , PLT_PositionInfo* info
                                 , void*  userdata );
    
    void OnGetVolumeResult( NPT_Result res
                           , PLT_DeviceDataReference& device
                           , const char*  channel
                           , NPT_UInt32	volume
                           , void* userdata );
    
    void OnGetMediaInfoResult( NPT_Result res
                              , PLT_DeviceDataReference& device
                              , PLT_MediaInfo* info
                              , void* userdata );
    
    void OnPlayResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );
    
    void OnPauseResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );
    
    void OnStopResult( NPT_Result res
                       , PLT_DeviceDataReference& device
                       , void* userdata );
    
    void OnSeekResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );
    
    void OnSetVolumeResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );
    
    void OnSetMuteResult( NPT_Result res
                           , PLT_DeviceDataReference& device
                           , void* userdata );
    
    void OnNextResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );
    
    void OnPreviousResult( NPT_Result res
                      , PLT_DeviceDataReference& device
                      , void* userdata );

    void OnGetTransportInfoResult( NPT_Result res
                                  , PLT_DeviceDataReference& device
                                  , PLT_TransportInfo* info
                                  , void* userdata );
    
    void OnSetPlayModeResult( NPT_Result res
                             , PLT_DeviceDataReference& device
                             , void* userdata );
    
    void OnMRStateVariablesChanged(PLT_Service *service
                                   , NPT_List<PLT_StateVariable*> *vars);
    
    NSDictionary* allRenders();
    
private:
    std::list<PLT_DeviceDataReference> renders_;
};

#endif