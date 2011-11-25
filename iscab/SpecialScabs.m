//
//  SpecialScabs.m
//  iscab
//
//  Created by Scott Wainstock on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpecialScabs.h"
#import "SpecialScabDetail.h"
#import "AppDelegate.h"

@implementation SpecialScabs

+ (id)scene {
    CCScene *scene = [CCScene node];
    SpecialScabs *layer = [SpecialScabs node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {    
    if ((self = [super init])) {
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
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CCMenu *scabMenu = [CCMenu menuWithItems:nil];
    
    for (NSString *scabName in [SpecialScabs specialScabNames]) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:[NSString stringWithFormat:@"iscab_%@", scabName]]) {
            CCMenuItem *scabMenuItem = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"%@.png", scabName] selectedImage:[NSString stringWithFormat:@"%@_Tap.png", scabName] target:self selector:@selector(specialScabTapped:)];
            
            [scabMenuItem setUserData:scabName];

            if ([scabName isEqualToString:@"xxx"])
                scabMenuItem.position = ccp(120, 205);
            
            if ([scabName isEqualToString:@"sass"])
                scabMenuItem.position = ccp(190, 205);
            
            if ([scabName isEqualToString:@"jesus"])
                scabMenuItem.position = ccp(90, 255);
            
            if ([scabName isEqualToString:@"heart"])
                scabMenuItem.position = ccp(160, 285);
            
            if ([scabName isEqualToString:@"illuminati"])
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
	 [CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SpecialScabDetail nodeWithScabName:menuItem.userData]]];
}

@end