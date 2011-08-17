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
        self.position = ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]); 
        self.rotation = [coder decodeFloatForKey:@"rotation"];
    }
    
    return self; 
}

- (void)update {
    self.position = body->p;
    self.rotation = CC_RADIANS_TO_DEGREES(-1 * body->a);
}

- (void)createBodyAtLocation:(CGPoint)location {
    float mass = 1.0;
    body = cpBodyNew(mass, cpMomentForBox(mass, self.contentSize.width, self.contentSize.height));
    
    body->p = location;
    body->data = self;
    //cpSpaceAddBody(space, body); //COMMENT THIS OUT TO STOP GRAVITY
    
    shape = cpBoxShapeNew(body, self.contentSize.width, self.contentSize.height);
    shape->e = 0.3; 
    shape->u = 1.0;
    shape->data = self;
    cpSpaceAddShape(space, shape);
}

- (id)initWithSpace:(cpSpace *)theSpace location:(CGPoint)location filename:(NSString *)filename {
    if ((self = [super initWithTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:filename]]])) {
        space = theSpace;
        [self createBodyAtLocation:location];
    }
    
    return self;
}

@end