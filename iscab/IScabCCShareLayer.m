//
//  IScabCCShareLayer.m
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabCCShareLayer.h"
#import "SpecialScabs.h"
#import "AppDelegate.h"
#import "SHK.h"

@implementation IScabCCShareLayer

@synthesize sharedItemFileName;

- (void)setupBackground {
    CCSprite *skinBG = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Jar_Background.jpg"]];
    skinBG.anchorPoint = ccp(0, 0);
    skinBG.position = ccp(0, 0);
    [self addChild:skinBG z:-10 tag:SKIN_BACKGROUND_TAG];
}

- (void)setupNavigationIcons {    
    CCMenuItem *backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    backButton.position = ccp(40, 40);
    
    CCMenuItem *specialButton = [CCMenuItemImage itemFromNormalImage:@"SpecialStar.png" selectedImage:@"SpecialStar_Tap.png" target:self selector:@selector(specialTapped:)];
    specialButton.position = ccp(165, 35);
    
    CCMenuItem *shareButton = [CCMenuItemImage itemFromNormalImage:@"Share.png" selectedImage:@"Share-Tap.png" target:self selector:@selector(shareTapped:)];
    shareButton.position = ccp(280, 40);
    
    CCMenu *iconMenu = [CCMenu menuWithItems:backButton, specialButton, shareButton, nil];
    iconMenu.position = CGPointZero;
    [self addChild:iconMenu z:2];
}

- (void)specialTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SpecialScabs scene]]];
}

- (void)shareTapped:(CCMenuItem *)menuItem {
    SHKItem *item = [SHKItem image:[UIImage imageNamed:self.sharedItemFileName] title:@"iScab"];
    
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [actionSheet showInView:[[CCDirector sharedDirector] openGLView]];
}

@end