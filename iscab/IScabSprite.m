//
//  IScabSprite.m
//  iscab
//
//  Created by Scott Wainstock on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabSprite.h"

@implementation IScabSprite

@synthesize body;

- (void)encodeWithCoder:(NSCoder *)coder {     
    [coder encodeInt:self.position.x forKey:@"xPos"]; 
    [coder encodeInt:self.position.y forKey:@"yPos"]; 
    [coder encodeFloat:self.rotation forKey:@"rotation"];
} 

- (id)initWithCoder:(NSCoder *)coder {    
    if (self != nil) {
        self.rotation = [coder decodeFloatForKey:@"rotation"];
        [self createBodyAtLocation:ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]) filename:@"scab0.png"];
    }
    
    return self; 
}

- (void)update {
    self.position = body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-1 * body->a);
}

- (void)addBodyWithVerts:(CGPoint[])verts atLocation:(CGPoint)location numVerts:(int)numVerts {    
    float mass = 0.1;
    float moment = cpMomentForPoly(mass, numVerts, verts, CGPointZero);
    body = cpBodyNew(mass, moment);
    
    body->p = location;
    body->data = self;
    
    shape = cpPolyShapeNew(body, numVerts, verts, CGPointZero);
    shape->e = 0.3; 
    shape->u = 1.0;
    shape->data = self;
    
    cpSpaceAddShape(space, shape);
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
        
        [self addBodyWithVerts:verts atLocation:location numVerts:18];
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
        
        [self addBodyWithVerts:verts atLocation:location numVerts:18];
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
        
        [self addBodyWithVerts:verts atLocation:location numVerts:13];
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
        
        [self addBodyWithVerts:verts atLocation:location numVerts:17];
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
        [self addBodyWithVerts:verts atLocation:location numVerts:14];
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
        
        [self addBodyWithVerts:verts atLocation:location numVerts:40];
    }
}

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename {
    if ((self = [super initWithSpriteFrameName:filename])) {        
        space = theSpace;
        [self createBodyAtLocation:location filename:filename];
    }
        
    return self;
}

- (void)destroy {
    NSLog(@"DESTROY");
    cpSpaceRemoveBody(space, body);
    cpSpaceRemoveShape(space, shape);
    [self removeFromParentAndCleanup:YES];
}

@end