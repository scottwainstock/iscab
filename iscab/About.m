//
//  About.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "About.h"
#import "AppDelegate.h"

@implementation About

+ (id)scene {
    CCScene *scene = [CCScene node];
    About *layer = [About node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        CCSprite *aboutText = [CCSprite spriteWithFile:@"about-text.png"];
        [aboutText setPosition:ccp(160, 236)];
        [self addChild:aboutText z:-1];
                
        CCMenuItemImage *ihodor = [CCMenuItemImage itemFromNormalImage:@"iHodor.png" selectedImage: @"iHodor-Tap.png" target:self selector:@selector(ihodorButtonPressed:)];
        
        CCMenu *menu = [CCMenu menuWithItems:ihodor, nil];       
        [menu setPosition:ccp(240, 150)];
        [self addChild:menu];        
    }
    
    return self;
}

- (IBAction)ihodorButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:IHODOR_URL]];
}

- (void)dealloc {
    [super dealloc];
}

@end