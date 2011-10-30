//
//  IScabCCLayer.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabCCLayer.h"
#import "MainMenu.h"
#import "JarScene.h"
#import "About.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

@implementation IScabCCLayer

- (id)init {
    if((self=[super init] )) {  
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"button.wav"];
        
        CCSprite *skinBG = [CCSprite spriteWithFile:@"clean-skin-background.png"];
        skinBG.anchorPoint = ccp(0, 0);
        skinBG.position = ccp(0, 0);
        [self addChild:skinBG z:-10];
        
        [self setupNavigationIcons];
    }

    return self;
}

- (void)setupNavigationIcons {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    app.backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    app.backButton.position = ccp(40, 40);
    
    app.jarButton = [CCMenuItemImage itemFromNormalImage:@"jar.png" selectedImage:@"Jar-Hover.png" target:self selector:@selector(jarTapped:)];
    app.jarButton.position = ccp(280, 40);
    
    CCMenu *menu = [CCMenu menuWithItems:app.backButton, app.jarButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
}

- (void)backTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] popScene];
}

- (void)aboutTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionPageTurn transitionWithDuration:0.5f scene:[About scene]]];
}

- (void)homeTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}

- (void)jarTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionPageTurn transitionWithDuration:0.5f scene:[JarScene scene]]];
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end