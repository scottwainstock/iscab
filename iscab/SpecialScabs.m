//
//  SpecialScabs.m
//  iscab
//
//  Created by Scott Wainstock on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpecialScabs.h"
#import "SpecialScabDetail.h"

@implementation SpecialScabs

+ (id)scene {
    CCScene *scene = [CCScene node];
    SpecialScabs *layer = [SpecialScabs node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {    
    if ((self=[super init])) {
        CCSprite *petriBottom = [CCSprite spriteWithFile:@"SpecialScabs_Petri_Bottom.png"];
        petriBottom.position = ccp(160, 240);
        [self addChild:petriBottom z:0];
        
        CCSprite *petriTop = [CCSprite spriteWithFile:@"SpecialScabs_Petri_Top.png"];
        petriTop.position = ccp(160, 240);
        [self addChild:petriTop z:4];
        
        [self addFoundScabs];
    }
    
    return self;
}

+ (NSArray *)specialScabNames {
    return [NSArray arrayWithObjects: @"xxx",@"heart",@"illuminati",@"jesus",@"sass",nil];
}

- (void)addFoundScabs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CCMenu *scabMenu = [CCMenu menuWithItems:nil];
    
    NSArray *specialScabs = [SpecialScabs specialScabNames];

    for (int i = 0; i < [specialScabs count]; i++) {
        NSString *scabName = [specialScabs objectAtIndex:i];
        if ([defaults valueForKey:scabName]) {
            CCMenuItem *scabMenuItem = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"%@.png", scabName] selectedImage:[NSString stringWithFormat:@"%@_Tap.png", scabName] target:self selector:@selector(specialScabTapped:)];
            
            [scabMenuItem setUserData:scabName];

            if ([[specialScabs objectAtIndex:i] isEqualToString:@"xxx"])
                scabMenuItem.position = ccp(120, 205);
            
            if ([[specialScabs objectAtIndex:i] isEqualToString:@"sass"])
                scabMenuItem.position = ccp(190, 205);
            
            if ([[specialScabs objectAtIndex:i] isEqualToString:@"jesus"])
                scabMenuItem.position = ccp(90, 255);
            
            if ([[specialScabs objectAtIndex:i] isEqualToString:@"heart"])
                scabMenuItem.position = ccp(160, 285);
            
            if ([[specialScabs objectAtIndex:i] isEqualToString:@"illuminati"])
                scabMenuItem.position = ccp(225, 265);
            
            [scabMenu addChild:scabMenuItem];
        }
    }
    
    scabMenu.position = CGPointZero;
    [self addChild:scabMenu z:2];
}

- (void)specialScabTapped:(CCMenuItem  *)menuItem {
    NSLog(@"TAPPY %@", (NSString *)menuItem.userData);
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionCrossFade transitionWithDuration:0.5f scene:[SpecialScabDetail nodeWithScabName:menuItem.userData]]];
}

- (void)setupBackground {
    CCSprite *skinBG = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Jar_Background.jpg"]];
    skinBG.anchorPoint = ccp(0, 0);
    skinBG.position = ccp(0, 0);
    [self addChild:skinBG z:-10 tag:SKIN_BACKGROUND_TAG];
}

- (void)setupNavigationIcons {    
    CCMenuItem *backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    backButton.position = ccp(40, 40);
    
    CCMenu *iconMenu = [CCMenu menuWithItems:backButton, nil];
    iconMenu.position = CGPointZero;
    [self addChild:iconMenu z:2];
}

@end