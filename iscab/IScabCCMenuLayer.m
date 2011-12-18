//
//  IScabCCMenuLayer.m
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabCCMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "CCMenuWideTouch.h"
#import "AppDelegate.h"

@implementation IScabCCMenuLayer

@synthesize menu;

- (id)init {
    if ((self = [super init])) {
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"menu_sound.mp3"];

        menu = [CCMenu menuWithItems:nil];
        [menu retain];
        
        [self setupNavigationIcons];
    }
    
    return self;
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"menu_sound.mp3"];
}

- (void)setupNavigationIcons {
    backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    [backButton setPosition:ccp(40, 40)];
    [backButton retain];
    
    iconMenu = [CCMenuWideTouch menuWithItems:backButton, nil];
    [iconMenu setMinTouchRect:CGRectMake(0, 0, ICON_TOUCH_AREA_SIZE, ICON_TOUCH_AREA_SIZE)];
    [iconMenu setPosition:CGPointZero];
    [self addChild:iconMenu z:2];
    [iconMenu retain];
}

- (void)backTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionMoveInL class] duration:TRANSITION_SPEED];
}

- (void) dealloc { 
    [menu release];
    [super dealloc];
} 

@end