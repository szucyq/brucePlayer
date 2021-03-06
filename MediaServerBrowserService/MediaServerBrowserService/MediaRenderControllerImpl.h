//
//  MediaRenderControllerImpl.h
//  MediaServerBrowserService
//
//  Created by Eason Zhao on 15/6/29.
//  Copyright (c) 2015年 Eason. All rights reserved.
//

#import "MediaRenderControllerService.h"
#include "Platinum/Platinum.h"

@interface MediaRenderControllerImpl : MediaRenderController

- (id)initWithController:(PLT_DeviceDataReference)device
              controller:(PLT_MediaController*)controller;

@end
