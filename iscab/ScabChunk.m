//
//  ScabChunk.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScabChunk.h"
#import "Wound.h"
#import "CCParticleMyBlood.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation ScabChunk

@synthesize priority, health, free, action, scabNo;

AppDelegate *app;

- (CGRect)rect {
    CGSize size = [self.texture contentSize];
    return CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height);
}

- (BOOL)containsTouchLocation:(UITouch *)touch {
    return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}
/*

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"TOUCH");
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    cpMouseGrab(mouse, touchLocation, false);
    return YES;

    if (![self containsTouchLocation:touch]) 
        return NO;
        
    if ([self health] > 0) {
        self.health -= 1;
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % 3]];
    
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self health] > 0) {
        return;
    }
   
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    if (([self health] <= 0) && !free) {
        [self ripOffScab];
    }
    
    [self setPosition:touchPoint];
}
*/
- (void)ripOffScab {
    free= YES;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
    
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc]init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = ccp(25,25);
    [self addChild:particles z:9];
    particles.autoRemoveOnFinish = YES;
    
    [self createWound];
}

- (void)createWound {
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    Wound *wound = [Wound spriteWithTexture:[self texture]];
    [wound setTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"wound0.png"]]];
    wound.rotation = self.rotation;
    wound.position = ccp(self.position.x, self.position.y);
    wound.scabNo = self.scabNo;

    [app.allWounds addObject:wound];
    [self.parent addChild:wound z:0];
}

- (void)removeScab {
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [app removeScab:self initing:NO];
}
/*
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    //280 and 40 correspond to the location of the jar
    float xDif = self.position.x - 280;
    float yDif = self.position.y - 40;
    float distance = sqrt(xDif * xDif + yDif * yDif);
        
    if (distance < 20) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabinjar.wav"];
        [self removeScab];
    } else if (self.free) {        
        [self runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:ccp(self.position.x,-100)], [CCCallFunc actionWithTarget:self selector:@selector(removeScab)], nil]];
    }
}
*/
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInt:self.health forKey:@"health"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeInt:self.scabNo forKey:@"scabNo"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[ScabChunk alloc] initWithTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"scab%d.png", [coder decodeIntForKey:@"scabNo"]]]]];

    if (self != nil) {
        self.scabNo = [coder decodeIntForKey:@"scabNo"];
        self.health = [coder decodeIntForKey:@"health"];
        self.priority = [coder decodeIntForKey:@"priority"];
    }
    
    [super initWithCoder:coder];
        
    return self; 
}

@end