//
//  CCMenuWideTouch.m
//  iscab
//
//  Created by Scott Wainstock on 12/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCMenuWideTouch.h"

@implementation CCMenuWideTouch

@synthesize minTouchRect;

- (CCMenuItem *)itemForTouch:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInView: [touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    
    CCMenuItem *item;
    CCARRAY_FOREACH(children_, item) {
        if ([item visible] && [item isEnabled]) {
            CGPoint local = [item convertToNodeSpace:touchLocation];
            CGRect r = [item rect];
            r.origin = CGPointZero;
            if (minTouchRect.size.width > r.size.width) {
                r.origin.x = (r.size.width - minTouchRect.size.width) / 2;
                r.size.width = minTouchRect.size.width;
            }
            
            if (minTouchRect.size.height > r.size.height) {
                r.origin.y = (r.size.height - minTouchRect.size.height) / 2;
                r.size.height = minTouchRect.size.height;
            }
            
            if(CGRectContainsPoint(r, local))
                return item;
        }
    }
    
    return nil;
}

@end