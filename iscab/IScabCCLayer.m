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
        
        CCSprite *paperBG = [CCSprite spriteWithFile:@"PaperBckgrnd.png"];
        paperBG.anchorPoint = ccp(0, 0);
        paperBG.position = ccp(0, 0);
        [self addChild:paperBG z:-9];
    
        [self setupNavigationIcons];
    }

    return self;
}

- (void)setupNavigationIcons {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    app.homeButton = [CCMenuItemImage itemFromNormalImage:@"Home.png" selectedImage:@"Home-Over.png" target:self selector:@selector(homeTapped:)];
    app.homeButton.position = ccp(40, 40);
    
    app.jarButton = [CCMenuItemImage itemFromNormalImage:@"jar.png" selectedImage:@"Jar-Hover.png" target:self selector:@selector(jarTapped:)];
    app.jarButton.position = ccp(280, 40);
    
    CCMenu *menu = [CCMenu menuWithItems:app.homeButton, app.jarButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
}

- (void)aboutTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] replaceScene:[About scene]];
}

- (void)homeTapped:(CCMenuItem  *)menuItem {    
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}

- (void)jarTapped:(CCMenuItem  *)menuItem { 
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeUp transitionWithDuration:0.5f scene:[JarScene scene]]];
}

- (void)playMenuSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.wav"];
}

@end