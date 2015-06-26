//
//  WithLeftRightController.h
//  GuanJia
//
//  Created by andone on 14-7-1.
//  Copyright (c) 2014年 andone. All rights reserved.
//

#import "WithRequestViewController.h"

@interface WithLeftRightController : WithRequestViewController

- (void)setCustomBackButtonText:(NSString *)backButtonTitle withImgName:(NSString*)sender;
- (void)setCustomRightButtonText:(NSString *)rightButtonTitle withImgName:(NSString*)sender;
-  (UIButton*)titleViewWithTitle:(NSString*)sender;
@end
