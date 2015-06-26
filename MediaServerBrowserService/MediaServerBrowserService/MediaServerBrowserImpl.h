//
//  MediaServerBrowserImpl.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/25.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaServerBrowserService.h"
#include "Platinum/Platinum.h"

@interface MediaServerBrowserImpl : MediaServerBrowser 

- (id)initWithDelegate:(id)delegate
                device:(PLT_DeviceDataReference) device
            controller:(PLT_MediaBrowser*)controller;

@end
