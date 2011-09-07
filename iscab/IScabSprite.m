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
   // if (collisionType == BLOOD_COLLISION_TYPE) {
   //     cpSpaceAddBody(space, body);
   // }
    
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
            cpv(-1.0f, -25.0f),
            cpv(-7.0f, -24.0f),
            cpv(-13.0f, -21.0f),
            cpv(-16.0f, -19.0f),
            cpv(-18.0f, -17.0f),
            cpv(-20.0f, -14.0f),
            cpv(-23.0f, -8.0f),
            cpv(-24.0f, -3.0f),
            cpv(-24.0f, 1.0f),
            cpv(-23.0f, 6.0f),
            cpv(-20.0f, 12.0f),
            cpv(-18.0f, 15.0f),
            cpv(-16.0f, 17.0f),
            cpv(-13.0f, 19.0f),
            cpv(-7.0f, 22.0f),
            cpv(-1.0f, 23.0f),
            cpv(1.0f, 23.0f),
            cpv(6.0f, 22.0f),
            cpv(9.0f, 21.0f),
            cpv(11.0f, 20.0f),
            cpv(14.0f, 18.0f),
            cpv(19.0f, 13.0f),
            cpv(22.0f, 7.0f),
            cpv(23.0f, 4.0f),
            cpv(23.0f, -6.0f),
            cpv(22.0f, -9.0f),
            cpv(19.0f, -15.0f),
            cpv(13.0f, -21.0f),
            cpv(9.0f, -23.0f),
            cpv(6.0f, -24.0f),
            cpv(1.0f, -25.0f)
        };

        [self addBodyWithVerts:verts atLocation:location numVerts:31 collisionType:SCAB_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"scab1.png"]) {
        CGPoint verts[] = {
            cpv(-1.0f, -25.0f),
            cpv(-7.0f, -24.0f),
            cpv(-13.0f, -21.0f),
            cpv(-16.0f, -19.0f),
            cpv(-18.0f, -17.0f),
            cpv(-20.0f, -14.0f),
            cpv(-23.0f, -8.0f),
            cpv(-24.0f, -3.0f),
            cpv(-24.0f, 1.0f),
            cpv(-23.0f, 6.0f),
            cpv(-20.0f, 12.0f),
            cpv(-18.0f, 15.0f),
            cpv(-16.0f, 17.0f),
            cpv(-13.0f, 19.0f),
            cpv(-7.0f, 22.0f),
            cpv(-1.0f, 23.0f),
            cpv(1.0f, 23.0f),
            cpv(6.0f, 22.0f),
            cpv(9.0f, 21.0f),
            cpv(11.0f, 20.0f),
            cpv(14.0f, 18.0f),
            cpv(19.0f, 13.0f),
            cpv(22.0f, 7.0f),
            cpv(23.0f, 4.0f),
            cpv(23.0f, -6.0f),
            cpv(22.0f, -9.0f),
            cpv(19.0f, -15.0f),
            cpv(13.0f, -21.0f),
            cpv(9.0f, -23.0f),
            cpv(6.0f, -24.0f),
            cpv(1.0f, -25.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:31 collisionType:SCAB_COLLISION_TYPE];
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
    } else if ([filename isEqualToString:@"clean_skin0.png"]) {
        CGPoint verts[] = {
            cpv(-4.0f, -25.0f),
            cpv(-8.0f, -24.0f),
            cpv(-12.0f, -22.0f),
            cpv(-15.0f, -20.0f),
            cpv(-19.0f, -16.0f),
            cpv(-21.0f, -13.0f),
            cpv(-22.0f, -11.0f),
            cpv(-24.0f, -4.0f),
            cpv(-24.0f, 2.0f),
            cpv(-22.0f, 9.0f),
            cpv(-18.0f, 15.0f),
            cpv(-16.0f, 17.0f),
            cpv(-13.0f, 19.0f),
            cpv(-7.0f, 22.0f),
            cpv(-2.0f, 23.0f),
            cpv(1.0f, 23.0f),
            cpv(6.0f, 22.0f),
            cpv(9.0f, 21.0f),
            cpv(13.0f, 19.0f),
            cpv(19.0f, 13.0f),
            cpv(21.0f, 10.0f),
            cpv(22.0f, 8.0f),
            cpv(23.0f, 5.0f),
            cpv(23.0f, -7.0f),
            cpv(22.0f, -10.0f),
            cpv(20.0f, -14.0f),
            cpv(17.0f, -18.0f),
            cpv(16.0f, -19.0f),
            cpv(10.0f, -23.0f),
            cpv(3.0f, -25.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:30 collisionType:WOUND_COLLISION_TYPE];
    } else if ([filename isEqualToString:@"bloody_skin0.png"]) {
        CGPoint verts[] = {
            cpv(-2.0f, -25.0f),
            cpv(-7.0f, -24.0f),
            cpv(-10.0f, -23.0f),
            cpv(-16.0f, -19.0f),
            cpv(-18.0f, -17.0f),
            cpv(-20.0f, -14.0f),
            cpv(-23.0f, -8.0f),
            cpv(-24.0f, -3.0f),
            cpv(-24.0f, 1.0f),
            cpv(-23.0f, 6.0f),
            cpv(-20.0f, 12.0f),
            cpv(-18.0f, 15.0f),
            cpv(-16.0f, 17.0f),
            cpv(-10.0f, 21.0f),
            cpv(-7.0f, 22.0f),
            cpv(-2.0f, 23.0f),
            cpv(2.0f, 23.0f),
            cpv(7.0f, 22.0f),
            cpv(13.0f, 19.0f),
            cpv(20.0f, 12.0f),
            cpv(22.0f, 8.0f),
            cpv(23.0f, 5.0f),
            cpv(24.0f, 0.0f),
            cpv(24.0f, -2.0f),
            cpv(23.0f, -7.0f),
            cpv(22.0f, -10.0f),
            cpv(20.0f, -14.0f),
            cpv(13.0f, -21.0f),
            cpv(7.0f, -24.0f),
            cpv(2.0f, -25.0f)
        };
        
        [self addBodyWithVerts:verts atLocation:location numVerts:30 collisionType:WOUND_COLLISION_TYPE];
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