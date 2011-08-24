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

@interface IScabSprite : CCSprite {
    cpBody *body;
    cpShape *shape;
    cpSpace *space;
    
    CGPoint savedLocation;
}

@property (nonatomic, assign) CGPoint savedLocation;

- (id)initWithLocation:(CGPoint)location filename:(NSString *)filename;
- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename;
- (void)update;
- (void)destroy;
- (void)createBodyAtLocation:(CGPoint)location filename:(NSString *)filename;
- (void)addBodyWithVerts:(CGPoint[])verts atLocation:(CGPoint)location numVerts:(int)numVerts collisionType:(int)collisionType;

@end