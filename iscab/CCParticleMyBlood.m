//
//  CCParticleMyBlood.m
//  iscab
//
//  Created by Scott Wainstock on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCParticleMyBlood.h"

@implementation CCParticleMyBlood

- (id)init {
    return [self initWithTotalParticles:955];
}

- (id)initWithTotalParticles:(int)numParticles {
    if ((self=[super initWithTotalParticles:numParticles])) {
        duration = 0.01f;
        self.emitterMode = kCCParticleModeGravity;
        self.gravity = ccp(-118,-2013);
        
        self.speed = 0;
        self.speedVar = 440.7;
        
        self.tangentialAccel = 0;
        self.tangentialAccelVar = 0;
        
        angle = 360;
        angleVar = 360;
        
        posVar = CGPointZero;
        
        life = 0;
        lifeVar = 0.724;
        
        startSize = 3;
        startSizeVar = 2.0f;
        endSize = kCCParticleStartSizeEqualToEndSize;
        
        emissionRate = totalParticles/duration;
        
        startColor.r = 1.0f;
        startColor.g = 0.0f;
        startColor.b = 0.0f;
        startColor.a = 1.0f;
        startColorVar.r = 0.0f;
        startColorVar.g = 0.0f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.0f;
        endColor.r = 1;
        endColor.g = 0.0f;
        endColor.b = 0.0f;
        endColor.a = 1.0f;
        endColorVar.r = 0.0f;
        endColorVar.g = 0.0f;
        endColorVar.b = 0.0f;
        endColorVar.a = 0.0f;
        
        self.blendAdditive = NO;
    }
    
    return self;
}

@end