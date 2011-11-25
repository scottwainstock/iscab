//
//  ScabChunk.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScabChunk.h"
#import "Wound.h"
#import "SimpleAudioEngine.h"
#import "GamePlay.h"
#import "AppDelegate.h"

@implementation ScabChunk

@synthesize priority, health, type, scab;

- (NSString *)filename {
    return [NSString stringWithFormat:@"%@_scab%d.png", self.type, self.scabChunkNo];
}

- (void)ripOffScab {
    //[[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
        
    if (ccpDistance(self.savedLocation, self.scab.center) < DISTANCE_FROM_CENTER_TO_REMAIN_CLEAN) {
        [self.scab createWoundFromIScabSprite:self isClean:NO];
    } else {
        [self.scab createWoundFromIScabSprite:self isClean:YES];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {    
    [coder encodeInt:self.position.x forKey:@"xPos"]; 
    [coder encodeInt:self.position.y forKey:@"yPos"]; 
    [coder encodeInt:self.health forKey:@"health"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeInt:self.scabChunkNo forKey:@"scabChunkNo"];
    [coder encodeObject:(NSString *)self.type forKey:@"type"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[ScabChunk alloc] init];
    
    if (self != nil) {
        self.savedLocation = ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]);
        self.scabChunkNo = [coder decodeIntForKey:@"scabChunkNo"];
        self.health = [coder decodeIntForKey:@"health"];
        self.priority = [coder decodeIntForKey:@"priority"];
        self.type = (NSString *)[coder decodeObjectForKey:@"type"];
    }
    
    return self; 
}

- (void)destroy {
    [self.scab.scabChunks removeObject:self];
    [super destroy];
}

- (void)dealloc {
    [type release];
    [scab release];
    [super dealloc];
}

@end