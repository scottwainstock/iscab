//
//  IScabSprite.h
//  iscab
//
//  Created by Scott Wainstock on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@interface IScabSprite : CCSprite <NSCoding> {
    cpBody *body;
    cpShape *shape;
    cpSpace *space;
}

@property (assign) cpBody *body;

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename;
- (void)update;
- (void)createBodyAtLocation:(CGPoint)location;

@end