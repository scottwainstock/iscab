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

@synthesize priority, health, free, action, scabNo;

- (void)ripOffScab {
    free= YES;
    [[SimpleAudioEngine sharedEngine] playEffect:@"scabrip.wav"];
    
    NSLog(@"LOCALE %@", NSStringFromCGPoint(self.savedLocation));
    if (ccpDistance(self.savedLocation, ccp(230, 160)) < 150.0) {
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