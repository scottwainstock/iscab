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
#import "SimpleAudioEngine.h"
#import "GamePlay.h"

@implementation ScabChunk

@synthesize priority, health, free, action, scabNo;

- (void)ripOffScab {
    free= YES;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
     
    /*
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc]init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = ccp(25,25);
    [self addChild:particles z:9];
    particles.autoRemoveOnFinish = YES;
    */
    
    [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] createWound:self];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInt:self.health forKey:@"health"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeInt:self.scabNo forKey:@"scabNo"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"scab%d.png", [coder decodeIntForKey:@"scabNo"]]];
    
    if (self != nil) {
        self.scabNo = [coder decodeIntForKey:@"scabNo"];
        self.health = [coder decodeIntForKey:@"health"];
        self.priority = [coder decodeIntForKey:@"priority"];
    }
    
    [super initWithCoder:coder];
        
    return self; 
}

@end