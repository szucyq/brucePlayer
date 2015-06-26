//
//  UIWindow+BPScaling.h
//  BPAppScale
//
//  Created by Brian Partridge on 10/30/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat BPScaleDefault;
extern CGFloat BPScaleiPadMiniOniPad;

@interface UIWindow (BPScaling)

@property (nonatomic, assign) CGFloat bp_globalWindowScale;

@end
