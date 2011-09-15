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

@synthesize priority, health, action, scabNo;

- (void)ripOffScab {
    //[[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
        
    if (ccpDistance(self.savedLocation, [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] centerOfScab]) < 75.0) {
        [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] createWound:self cleanSkin:NO];
    } else {
        [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] createWound:self cleanSkin:YES];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.position.x forKey:@"xPos"]; 
    [coder encodeInt:self.position.y forKey:@"yPos"]; 
    [coder encodeInt:self.health forKey:@"health"];
    [coder encodeInt:self.priority forKey:@"priority"];
    [coder encodeInt:self.scabNo forKey:@"scabNo"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[ScabChunk alloc] init];
    
    if (self != nil) {
        self.savedLocation = ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]);
        self.scabNo = [coder decodeIntForKey:@"scabNo"];
        self.health = [coder decodeIntForKey:@"health"];
        self.priority = [coder decodeIntForKey:@"priority"];
    }
    
    return self; 
}

@end