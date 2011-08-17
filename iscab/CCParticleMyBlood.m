//
//  CCParticleMyBlood.m
//  iscab
//
//  Created by Scott Wainstock on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCParticleMyBlood.h"

@implementation CCParticleMyBlood

-(id) init {
    return [self initWithTotalParticles:955];
}

-(id) initWithTotalParticles:(int)p {
    if( (self=[super initWithTotalParticles:p]) ) {
        
        duration = 0.01f;
        self.emitterMode = kCCParticleModeGravity;
        self.gravity = ccp(-118,-2013);
        
        // Gravity Mode: speed of particles
        self.speed = 0;
        self.speedVar = 440.7;
        
        // Gravity Mode: tagential
        self.tangentialAccel = 0;
        self.tangentialAccelVar = 0;
        
        // angle
        angle = 360;
        angleVar = 360;
        
        // emitter position
      //  CGSize winSize = [[CCDirector sharedDirector] winSize];
      //  self.position = ccp(winSize.width/2, winSize.height/2);
        posVar = CGPointZero;
        
        // life of particles
        life = 0;
        lifeVar = 0.724;
        
        // size, in pixels
        startSize = 3;
        startSizeVar = 2.0f;
        endSize = kCCParticleStartSizeEqualToEndSize;
        
        // emits per second
        emissionRate = totalParticles/duration;
        
        // color of particles
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