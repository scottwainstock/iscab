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

@implementation IScabCCLayer

- (id)init {
    if((self=[super init] )) {  
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"button.wav"];
    
        [self setupNavigationIcons];
    }

    return self;
}

- (void)setupNavigationIcons {
    CCMenuItem *homeButton = [CCMenuItemImage itemFromNormalImage:@"Home.png" selectedImage:@"Home-Over.png" target:self selector:@selector(homeTapped:)];
    homeButton.position = ccp(40, 40);
    
    CCMenuItem *jarButton = [CCMenuItemImage itemFromNormalImage:@"Jar.png" selectedImage:@"Jar-Hover.png" target:self selector:@selector(jarTapped:)];
    jarButton.position = ccp(280, 40);
    
    CCMenu *menu = [CCMenu menuWithItems:homeButton, jarButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
}

- (void)aboutTapped:(CCMenuItem  *)menuItem {
    NSLog(@"ABOUT TAPPED");
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFadeUp transitionWithDuration:0.5f scene:[About scene]]];
}

- (void)homeTapped:(CCMenuItem  *)menuItem {    
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFadeUp transitionWithDuration:0.5f scene:[MainMenu scene]]];
}

- (void)jarTapped:(CCMenuItem  *)menuItem { 
    NSLog(@"JAR TAPPED");
    [[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFadeUp transitionWithDuration:0.5f scene:[JarScene scene]]];
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end