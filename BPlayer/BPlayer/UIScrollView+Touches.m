//
//  UIScrollView+Touches.m
//  CarPaper
//
//  Created by andone on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIScrollView+Touches.h"


@implementation UIScrollView(MyScrollViewTouches)

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.dragging) {
        
        [self.nextResponder touchesBegan:touches withEvent:event];
        
    } else {
        
        [super touchesEnded:touches withEvent:event];
        
    }
//    [[self nextResponder] touchesBegan:touches withEvent:event];
    //[super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event

{
    
    // If not dragging, send event to next responder
    
    if (!self.dragging) {
        
        [self.nextResponder touchesBegan:touches withEvent:event];
        
    } else {
        
        [super touchesEnded:touches withEvent:event];
        
    }
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

{
    
    // If not dragging, send event to next responder
    
    if (!self.dragging) {
        
        [self.nextResponder touchesBegan:touches withEvent:event];
        
    } else {
        
        [super touchesEnded:touches withEvent:event];
        
    }
    
}
@end
