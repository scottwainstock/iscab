//
//  IScabSprite.m
//  iscab
//
//  Created by Scott Wainstock on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabSprite.h"
#import "GamePlay.h"
#import "cpShape.h"

#define MASS 0.1
#define SCAB_COLLISION_TYPE  1
#define WOUND_COLLISION_TYPE 2
#define BLOOD_COLLISION_TYPE 3

@implementation IScabSprite

@synthesize savedLocation;

- (void)update {
    self.position = body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-1 * body->a);
}

- (void)addBodyWithVerts:(CGPoint[])verts atLocation:(CGPoint)location numVerts:(int)numVerts collisionType:(int)collisionType {    
    float moment = cpMomentForPoly(MASS, numVerts, verts, CGPointZero);
    body = cpBodyNew(MASS, moment);
    
    body->p = location;
    body->data = self;
    
    shape = cpPolyShapeNew(body, numVerts, verts, CGPointZero);
    shape->e = 0.3; 
    shape->u = 1.0;
    shape->collision_type = collisionType;
    shape->data = self;

//    if (collisionType != BLOOD_COLLISION_TYPE) {
        cpSpaceAddShape(space, shape);
//    }
}

- (void)createBodyAtLocation:(CGPoint)location shapeNo:(int)shapeNo {    
    if (shapeNo == 0) {
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
    } else if (shapeNo == 1) {
        CGPoint verts[] = {
            cpv(-3.0f, -6.0f),
            cpv(-6.0f, -3.0f),
            cpv(-6.0f, 2.0f),
            cpv(-3.0f, 5.0f),
            cpv(2.0f, 5.0f),
            cpv(5.0f, 2.0f),
            cpv(5.0f, -3.0f),
            cpv(2.0f, -6.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:8 collisionType:WOUND_COLLISION_TYPE];
    } else if (shapeNo == 2) {
        CGPoint verts[] = {
            cpv(-3.0f, -8.0f),
            cpv(-5.0f, -7.0f),
            cpv(-7.0f, -5.0f),
            cpv(-8.0f, -3.0f),
            cpv(-8.0f, 2.0f),
            cpv(-7.0f, 4.0f),
            cpv(-5.0f, 6.0f),
            cpv(-3.0f, 7.0f),
            cpv(2.0f, 7.0f),
            cpv(4.0f, 6.0f),
            cpv(6.0f, 4.0f),
            cpv(7.0f, 2.0f),
            cpv(7.0f, -3.0f),
            cpv(6.0f, -5.0f),
            cpv(4.0f, -7.0f),
            cpv(2.0f, -8.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:16 collisionType:WOUND_COLLISION_TYPE];        
    } else if (shapeNo == 3) {
        CGPoint verts[] = {
            cpv(-4.0f, -10.0f),
            cpv(-6.0f, -9.0f),
            cpv(-9.0f, -6.0f),
            cpv(-10.0f, -4.0f),
            cpv(-10.0f, 3.0f),
            cpv(-9.0f, 5.0f),
            cpv(-6.0f, 8.0f),
            cpv(-4.0f, 9.0f),
            cpv(3.0f, 9.0f),
            cpv(5.0f, 8.0f),
            cpv(8.0f, 5.0f),
            cpv(9.0f, 3.0f),
            cpv(9.0f, -4.0f),
            cpv(8.0f, -6.0f),
            cpv(5.0f, -9.0f),
            cpv(3.0f, -10.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:16 collisionType:WOUND_COLLISION_TYPE];
    }
}

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename shapeNo:(int)shapeNo {
    if ((self = [super initWithSpriteFrameName:filename])) {     
        space = theSpace;
        savedLocation = location;
        [self createBodyAtLocation:savedLocation shapeNo:(int)shapeNo];  
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
   // NSLog(@"DESTROY");
    if (shape) {
        cpSpaceRemoveShape(space, shape);
    }
    [self removeFromParentAndCleanup:YES];
}

@end