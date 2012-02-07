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

@synthesize scabMenu;

- (void)dealloc {
    [scabMenu release];
    [super dealloc];
}

+ (id)scene {
    CCScene *scene = [CCScene node];
    SpecialScabs *layer = [SpecialScabs node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {    
    if ((self = [super init])) {
        CCSprite *petriBottom = [CCSprite spriteWithFile:@"SpecialScabs_Petri_Bottom.png"];
        [petriBottom setPosition:ccp(160, 240)];
        [self addChild:petriBottom z:0];
        
        CCSprite *petriTop = [CCSprite spriteWithFile:@"SpecialScabs_Petri_Top.png"];
        [petriTop setPosition:ccp(160, 240)];
        [self addChild:petriTop z:4];
    }
    
    return self;
}

- (void)onEnter {
    [self addFoundScabs];
    [super onEnter];
}

- (void)onExit {
    [scabMenu removeAllChildrenWithCleanup:YES];
    [super onExit];
}

+ (NSArray *)specialScabNames {
    return [NSArray arrayWithObjects:@"xxx", @"heart", @"illuminati", @"jesus", @"sass", nil];
}

- (void)addFoundScabs {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    scabMenu = [CCMenu menuWithItems:nil];
    [scabMenu retain];
    
    for (NSString *scabName in [SpecialScabs specialScabNames]) {
        if ([app.defaults boolForKey:scabName]) {
            CCMenuItem *scabMenuItem = [CCMenuItemImage itemFromNormalImage:[NSString stringWithFormat:@"%@.png", scabName] selectedImage:[NSString stringWithFormat:@"%@_Tap.png", scabName] target:self selector:@selector(specialScabTapped:)];
            
            [scabMenuItem setUserData:scabName];

            if ([scabName isEqualToString:@"xxx"])
                [scabMenuItem setPosition:ccp(120, 205)];
            else if ([scabName isEqualToString:@"sass"])
                [scabMenuItem setPosition:ccp(190, 205)];
            else if ([scabName isEqualToString:@"jesus"])
                [scabMenuItem setPosition:ccp(90, 255)];
            else if ([scabName isEqualToString:@"heart"])
                [scabMenuItem setPosition:ccp(160, 285)];
            else if ([scabName isEqualToString:@"illuminati"])
                [scabMenuItem setPosition:ccp(225, 265)];
            
            [scabMenu addChild:scabMenuItem];
        }
    }
    
    [scabMenu setPosition:CGPointZero];
    [self addChild:scabMenu z:2];
}

- (void)specialScabTapped:(CCMenuItem  *)menuItem {
    NSLog(@"TAPPY %@", (NSString *)menuItem.userData);
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SpecialScabDetail nodeWithScabName:menuItem.userData]]];
}

@end