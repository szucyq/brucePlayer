//
//  UIWindow+BPScaling.m
//  BPAppScale
//
//  Created by Brian Partridge on 10/30/12.
//  Copyright (c) 2012 Brian Partridge. All rights reserved.
//

#import "UIWindow+BPScaling.h"

#define DEFAULT_SCALE 1.0f

CGFloat BPScaleDefault = DEFAULT_SCALE;
CGFloat BPScaleiPadMiniOniPad = 4.71f/5.82f;

static CGFloat _currentScale = DEFAULT_SCALE;

@implementation UIWindow (BPScaling)

- (void)setBp_globalWindowScale:(CGFloat)bp_scale {
    _currentScale = bp_scale;
    [self bp_applyScaling];
}

- (CGFloat)bp_globalWindowScale {
    return _currentScale;
}

- (void)bp_applyScaling {
    [self bp_scaleWindow:self];

    [self bp_scaleStatusBarWindow];
    [self bp_scaleKeyboardWindow];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bp_statusBarChanged:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bp_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)bp_statusBarChanged:(NSNotification *)note {
    [self bp_scaleStatusBarWindow];
}

- (void)bp_scaleStatusBarWindow {
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(_currentScale, _currentScale);
    UIWindow *statusBarWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    statusBarWindow.transform = CGAffineTransformConcat(scaleTransform, statusBarWindow.transform);
}

static BOOL haveScaledCurrentKeyboard = NO;
- (void)bp_keyboardWillShow:(NSNotification *)note {
    // Perform on next run loop
    [self performSelector:(@selector(bp_scaleKeyboardWindow)) withObject:nil afterDelay:0];
}

- (void)bp_scaleKeyboardWindow {
    if (haveScaledCurrentKeyboard) {
        return;
    }

    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([window isKindOfClass:[NSClassFromString(@"UITextEffectsWindow") class]]) {
            [self bp_scaleWindow:window];
            haveScaledCurrentKeyboard = YES;
        }
    }
}

- (void)bp_scaleWindow:(UIWindow *)window {
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(_currentScale, _currentScale);
    window.transform = CGAffineTransformConcat(scaleTransform, window.transform);
    window.clipsToBounds = YES;
}

@end
