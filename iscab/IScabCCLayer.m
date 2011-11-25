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

        [self setupNavigationIcons];
    }

    return self;
}

- (void)onEnter {
    [super onEnter];
    [self setupBackground];
}

- (void)setupBackground {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [self removeChildByTag:SKIN_BACKGROUND_TAG cleanup:YES];

    CCSprite *skinBG;
    if ([[app.defaults objectForKey:@"skinColor"] isEqualToString:@"photo"]) {
        NSData *imageData = [app.defaults objectForKey:@"photoBackground"];
        UIImage *image = [UIImage imageWithData:imageData];
        skinBG = [CCSprite spriteWithCGImage:image.CGImage key:[NSString stringWithFormat:@"%d", (arc4random() % 1000) + 1]];
    } else {
        skinBG = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_skin_background2.jpg", [app.defaults objectForKey:@"skinColor"]]];
    }
    
    skinBG.anchorPoint = ccp(0, 0);
    skinBG.position = ccp(0, 0);
    [self addChild:skinBG z:-10 tag:SKIN_BACKGROUND_TAG];
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
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionCrossFade class] duration:TRANSITION_SPEED];
}

- (void)aboutTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[About scene]]];
}

- (void)homeTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}

- (void)jarTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[JarScene scene]]];
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end