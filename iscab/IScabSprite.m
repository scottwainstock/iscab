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
#define SCAB_COLLISION_TYPE 1
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
    if (collisionType == BLOOD_COLLISION_TYPE) {
        cpSpaceAddBody(space, body);
    }
    
    shape = cpPolyShapeNew(body, numVerts, verts, CGPointZero);
    shape->e = 0.3; 
    shape->u = 1.0;
    shape->collision_type = collisionType;
    shape->data = self;
        
    if (collisionType != BLOOD_COLLISION_TYPE) {
        cpSpaceAddShape(space, shape);
    }
}

- (void)createBodyAtLocation:(CGPoint)location filename:(NSString *)filename {    
    if ([filename isEqualToString:@"scab0.png"]) {
        CGPoint verts[] = {
            cpv(44.0f, -60.0f),
            cpv(-18.0f, -50.0f),
            cpv(-70.0f, -19.0f),
            cpv(-74.0f, -15.0f),
            cpv(-75.0f, -12.0f),
            cpv(-75.0f, 10.0f),
            cpv(-74.0f, 16.0f),
            cpv(-35.0f, 59.0f),
            cpv(45.0f, 54.0f),
            cpv(53.0f, 51.0f),
            cpv(56.0f, 49.0f),
            cpv(59.0f, 46.0f),
            cpv(63.0f, 33.0f),
            cpv(74.0f, -30.0f),
            cpv(74.0f, -43.0f),
            cpv(72.0f, -47.0f),
            cpv(71.0f, -48.0f),
            cpv(55.0f, -60.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:18 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"scab1.png"]) {
        CGPoint verts[] = {
            cpv(-37.0f, -60.0f),
            cpv(-39.0f, -59.0f),
            cpv(-40.0f, -58.0f),
            cpv(-42.0f, -55.0f),
            cpv(-63.0f, 34.0f),
            cpv(-62.0f, 35.0f),
            cpv(-56.0f, 40.0f),
            cpv(18.0f, 59.0f),
            cpv(30.0f, 59.0f),
            cpv(41.0f, 48.0f),
            cpv(63.0f, -10.0f),
            cpv(63.0f, -24.0f),
            cpv(62.0f, -33.0f),
            cpv(56.0f, -46.0f),
            cpv(54.0f, -49.0f),
            cpv(50.0f, -53.0f),
            cpv(47.0f, -54.0f),
            cpv(-32.0f, -60.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:18 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"scab2.png"]) {
        CGPoint verts[] = {
            cpv(3.5f, -23.0f),
            cpv(-37.5f, -21.0f),
            cpv(-37.5f, -20.0f),
            cpv(-36.5f, -18.0f),
            cpv(-10.5f, 20.0f),
            cpv(-8.5f, 22.0f),
            cpv(-2.5f, 22.0f),
            cpv(-0.5f, 21.0f),
            cpv(2.5f, 19.0f),
            cpv(35.5f, -10.0f),
            cpv(36.5f, -12.0f),
            cpv(36.5f, -14.0f),
            cpv(18.5f, -23.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:13 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"scab3.png"]) {
        CGPoint verts[] = {
            cpv(-34.5f, -26.5f),
            cpv(-37.5f, -24.5f),
            cpv(-38.5f, -23.5f),
            cpv(-43.5f, -16.5f),
            cpv(-43.5f, -13.5f),
            cpv(-37.5f, 14.5f),
            cpv(-36.5f, 15.5f),
            cpv(-7.5f, 24.5f),
            cpv(0.5f, 25.5f),
            cpv(36.5f, 23.5f),
            cpv(39.5f, 20.5f),
            cpv(42.5f, 13.5f),
            cpv(42.5f, -6.5f),
            cpv(40.5f, -12.5f),
            cpv(38.5f, -16.5f),
            cpv(34.5f, -20.5f),
            cpv(16.5f, -26.5f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:17 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"scab4.png"]) {
        CGPoint verts[] = {
            cpv(48.5f, -66.0f),
            cpv(-70.5f, -61.0f),
            cpv(-75.5f, 42.0f),
            cpv(-72.5f, 49.0f),
            cpv(-65.5f, 55.0f),
            cpv(-44.5f, 63.0f),
            cpv(28.5f, 66.0f),
            cpv(36.5f, 64.0f),
            cpv(40.5f, 62.0f),
            cpv(43.5f, 60.0f),
            cpv(48.5f, 55.0f),
            cpv(49.5f, 53.0f),
            cpv(74.5f, -30.0f),
            cpv(74.5f, -66.0f)
        };

        [self addBodyWithVerts:verts atLocation:location numVerts:14 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"wound0.png"]) {
        CGPoint verts[] = {
            cpv(-5.0f, -48.5f),
            cpv(-11.0f, -47.5f),
            cpv(-17.0f, -45.5f),
            cpv(-25.0f, -41.5f),
            cpv(-28.0f, -39.5f),
            cpv(-34.0f, -34.5f),
            cpv(-40.0f, -26.5f),
            cpv(-44.0f, -18.5f),
            cpv(-46.0f, -12.5f),
            cpv(-47.0f, -6.5f),
            cpv(-47.0f, 3.5f),
            cpv(-46.0f, 9.5f),
            cpv(-44.0f, 15.5f),
            cpv(-40.0f, 23.5f),
            cpv(-38.0f, 26.5f),
            cpv(-28.0f, 36.5f),
            cpv(-25.0f, 38.5f),
            cpv(-17.0f, 42.5f),
            cpv(-11.0f, 44.5f),
            cpv(-5.0f, 45.5f),
            cpv(5.0f, 45.5f),
            cpv(11.0f, 44.5f),
            cpv(17.0f, 42.5f),
            cpv(25.0f, 38.5f),
            cpv(28.0f, 36.5f),
            cpv(38.0f, 26.5f),
            cpv(40.0f, 23.5f),
            cpv(44.0f, 15.5f),
            cpv(46.0f, 9.5f),
            cpv(47.0f, 3.5f),
            cpv(47.0f, -6.5f),
            cpv(46.0f, -12.5f),
            cpv(44.0f, -18.5f),
            cpv(40.0f, -26.5f),
            cpv(38.0f, -29.5f),
            cpv(28.0f, -39.5f),
            cpv(25.0f, -41.5f),
            cpv(17.0f, -45.5f),
            cpv(11.0f, -47.5f),
            cpv(5.0f, -48.5f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:40 collisionType:WOUND_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"blood.png"]) {
        CGPoint verts[] = {
            cpv(-3.0f, -8.0f),
            cpv(-5.0f, -7.0f),
            cpv(-7.0f, -5.0f),
            cpv(-8.0f, -3.0f),
            cpv(-8.0f, 3.0f),
            cpv(-4.0f, 7.0f),
            cpv(3.0f, 7.0f),
            cpv(7.0f, 3.0f),
            cpv(7.0f, -4.0f),
            cpv(4.0f, -7.0f),
            cpv(2.0f, -8.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:11 collisionType:BLOOD_COLLISION_TYPE];
    }
}

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename {
    if ((self = [super initWithSpriteFrameName:filename])) {     
        space = theSpace;
        savedLocation = location;
        [self createBodyAtLocation:savedLocation filename:(NSString *)filename];  

        cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(arc4random() % 360));
    }
        
    return self;
}

- (id)initWithLocation:(CGPoint)location filename:(NSString *)filename {
    if ((self = [super initWithSpriteFrameName:filename])) {     
        self.position = location;
        savedLocation = location;
        
        return self;
    }
    
    return nil;
}

- (void)destroy {
    NSLog(@"DESTROY");
    if (shape) {
        cpSpaceRemoveShape(space, shape);
    }
    [self removeFromParentAndCleanup:YES];
}

@end