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
    cpShape *shape;
    cpSpace *space;    
    CGPoint savedLocation;
    
    @public
        cpBody *body;
}

@property (nonatomic, assign) CGPoint savedLocation;

- (void)update;
- (void)destroy;
- (void)createBodyAtLocation:(CGPoint)location shapeNo:(int)shapeNo;
- (void)addBodyWithVerts:(CGPoint[])verts atLocation:(CGPoint)location numVerts:(int)numVerts collisionType:(int)collisionType;
- (id)initWithLocation:(CGPoint)location filename:(NSString *)filename shapeNo:(int)shapeNo;
- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename shapeNo:(int)shapeNo;

@end