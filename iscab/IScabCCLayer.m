//
//  IScabCCLayer.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabCCLayer.h"
#import "MainMenu.h"
#import "SimpleAudioEngine.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation IScabCCLayer

- (id)init {
    if((self=[super init] )) {  
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"button.wav"];

        CCSprite *bg = [CCSprite spriteWithFile:@"clean-skin-background.png"];
        bg.anchorPoint = ccp(0, 0);
        bg.position = ccp(0, 0);
        [self addChild:bg z:0];

        CCMenuItem *homeButton = [CCMenuItemImage itemFromNormalImage:@"home-icon.png" selectedImage:@"home-icon.png" target:self selector:@selector(homeTapped:)];
        homeButton.position = ccp(40, 40);
        
        CCMenu *menu = [CCMenu menuWithItems:homeButton, nil];
        menu.position = CGPointZero;
        [self addChild:menu z:2];
    }

    return self;
}

- (void)addBackButton {
    CCMenuItem *backButton = [CCMenuItemImage itemFromNormalImage:@"back-icon.png" selectedImage:@"back-icon.png" target:self selector:@selector(backTapped:)];
    backButton.position = ccp(40, 400);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
}

- (void)homeTapped:(CCMenuItem  *)menuItem {    
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFadeUp transitionWithDuration:0.5f scene:[MainMenu scene]]];
}

- (void)backTapped:(CCMenuItem *)menuItem {
    [[CCDirector sharedDirector] popScene];
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end
