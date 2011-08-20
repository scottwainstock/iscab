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

- (void)ripOffScab {
    free= YES;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
    
    return;
    
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc]init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = ccp(25,25);
    [self addChild:particles z:9];
    particles.autoRemoveOnFinish = YES;
    
    [self createWound];
}

- (void)createWound {
    return;
    
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    Wound *wound = [Wound spriteWithTexture:[self texture]];
    [wound setTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"wound0.png"]]];
    wound.rotation = self.rotation;
    wound.position = ccp(self.position.x, self.position.y);
    wound.scabNo = self.scabNo;

    [app.allWounds addObject:wound];
    [self.parent addChild:wound z:0];
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