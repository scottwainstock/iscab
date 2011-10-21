//
//  IScabSprite.m
//  iscab
//
//  Created by Scott Wainstock on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabSprite.h"
#import "cpShape.h"

@implementation IScabSprite

@synthesize savedLocation, shape, scabChunkNo;

- (void)update {
    if (body) {        
        self.position = body->p;
        self.rotation = CC_RADIANS_TO_DEGREES(-1 * body->a);
    }
}

- (bool)isOffscreen {
    return CGRectContainsPoint([UIScreen mainScreen].bounds, self.position) ? FALSE : TRUE;
}

- (void)addBodyWithVerts:(CGPoint[])verts atLocation:(CGPoint)location numVerts:(int)numVerts collisionType:(int)collisionType {    
    float moment = cpMomentForPoly(MASS, numVerts, verts, CGPointZero);
    body = cpBodyNew(MASS, moment);
    
    body->p = location;
    body->data = self;
    cpSpaceAddBody(space, body);
    
    shape = cpPolyShapeNew(body, numVerts, verts, CGPointZero);
    shape->e = 1.0f; 
    shape->u = 1.0f;
    shape->data = self;
    shape->group = 1;
    self.shape = shape;
    //cpSpaceAddShape(space, shape);
}

- (void)createBodyAtLocation:(CGPoint)location shapeNo:(int)shapeNo {    
    if (shapeNo == 0) {
        CGPoint verts[] = {
            cpv(-1.0f, -2.0f),
            cpv(-2.0f, -1.0f),
            cpv(-2.0f, 0.0f),
            cpv(-1.0f, 1.0f),
            cpv(0.0f, 1.0f),
            cpv(1.0f, 0.0f),
            cpv(1.0f, -1.0f),
            cpv(0.0f, -2.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:8 collisionType:WOUND_COLLISION_TYPE];
    } else if (shapeNo == 1) {
        CGPoint verts[] = {
            cpv(-2.0f, -3.0f),
            cpv(-3.0f, -2.0f),
            cpv(-3.0f, 1.0f),
            cpv(-2.0f, 2.0f),
            cpv(1.0f, 2.0f),
            cpv(2.0f, 1.0f),
            cpv(2.0f, -2.0f),
            cpv(1.0f, -3.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:8 collisionType:WOUND_COLLISION_TYPE];
    } else if (shapeNo == 2) {
        CGPoint verts[] = {
            cpv(-2.0f, -4.0f),
            cpv(-4.0f, -2.0f),
            cpv(-4.0f, 1.0f),
            cpv(-2.0f, 3.0f),
            cpv(1.0f, 3.0f),
            cpv(3.0f, 1.0f),
            cpv(3.0f, -2.0f),
            cpv(1.0f, -4.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:8 collisionType:WOUND_COLLISION_TYPE];        
    } else if (shapeNo == 3) {
        CGPoint verts[] = {
            cpv(-2.0f, -5.0f),
            cpv(-4.0f, -4.0f),
            cpv(-5.0f, -2.0f),
            cpv(-5.0f, 1.0f),
            cpv(-4.0f, 3.0f),
            cpv(-2.0f, 4.0f),
            cpv(1.0f, 4.0f),
            cpv(3.0f, 3.0f),
            cpv(4.0f, 1.0f),
            cpv(4.0f, -2.0f),
            cpv(3.0f, -4.0f),
            cpv(1.0f, -5.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:12 collisionType:WOUND_COLLISION_TYPE];
    }
}

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename shapeNo:(int)shapeNo {
    if ((self = [super initWithSpriteFrameName:filename])) {     
        space = theSpace;
        savedLocation = location;
        [self createBodyAtLocation:location shapeNo:(int)shapeNo];  
    }
        
    return self;
}

- (id)initWithLocation:(CGPoint)location filename:(NSString *)filename shapeNo:(int)shapeNo {
    if ((self = [super initWithSpriteFrameName:filename])) {     
        self.position = location;
        savedLocation = location;
        
        return self;
    }
    
    return nil;
}

- (void)destroy {
    if (shape) {
        //cpSpaceRemoveShape(space, shape);
    }
    [self removeFromParentAndCleanup:YES];
}

@end