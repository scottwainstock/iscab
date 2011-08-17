//
//  MainMenu.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "GamePlay.h"
#import "Options.h"
#import "Help.h"
#import "JarScene.h"
#import "SimpleAudioEngine.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation MainMenu

+(id) scene {
    CCScene *scene = [CCScene node];
    MainMenu *layer = [MainMenu node];
    [scene addChild: layer];
    return scene;
}

-(id) init {
    if( (self=[super init] )) {
        [CCMenuItemFont setFontName:DEFAULT_FONT_NAME];
        [CCMenuItemFont setFontSize:DEFAULT_FONT_SIZE];
                
        CCSprite *bg = [CCSprite spriteWithFile:@"menu-background.png"];
        bg.anchorPoint = ccp(0, 0);
        bg.position = ccp(0, 0);
        [self addChild:bg z:0];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"iSCAB" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 2];
        title.position =  ccp(160, 380);
        [self addChild: title];

        CCMenuItemImage *startLabel = [CCMenuItemImage itemFromNormalImage:@"label1.png" selectedImage: @"label1.png" target:self selector:nil];
        startLabel.position = ccp(0, 70);
        CCMenuItemImage *jarLabel = [CCMenuItemImage itemFromNormalImage:@"label2.png" selectedImage: @"label2.png" target:self selector:nil];
        jarLabel.position = ccp(0, 0);
        CCMenuItemImage *optionsLabel = [CCMenuItemImage itemFromNormalImage:@"label3.png" selectedImage: @"label3.png" target:self selector:nil];
        optionsLabel.position = ccp(0, -70);
        CCMenuItemImage *helpLabel = [CCMenuItemImage itemFromNormalImage:@"label5.png" selectedImage: @"label5.png" target:self selector:nil];
        helpLabel.position = ccp(0, -140);

        CCMenu *labelMenu = [CCMenu menuWithItems:startLabel,jarLabel,optionsLabel,helpLabel,nil];
        [self addChild:labelMenu];
        
        CCMenuItem *start = [CCMenuItemFont itemFromString:@"START PICKIN'" target:self selector:@selector(startPickinTapped:)];
        CCMenuItem *jar = [CCMenuItemFont itemFromString:@"JAR" target:self selector:@selector(jarTapped:)];
        CCMenuItem *help = [CCMenuItemFont itemFromString:@"HELP" target:self selector:@selector(helpTapped:)];
        CCMenuItem *options = [CCMenuItemFont itemFromString:@"OPTIONS" target:self selector:@selector(optionsTapped:)];
    
        CCMenu *menu = [CCMenu menuWithItems:start,jar,options,help,nil];

        menu.position = ccp(160, 200);
        [menu alignItemsVerticallyWithPadding:30.0];
        [menu setColor:ccc3(0, 0, 0)];
        [self addChild:menu];        
    }
    
    return self;
}

- (void)startPickinTapped:(CCMenuItem  *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[GamePlay scene]]];
}

- (void)jarTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionFlipAngular transitionWithDuration:0.5f scene:[JarScene scene]]];
}

- (void)helpTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionShrinkGrow transitionWithDuration:0.5f scene:[Help scene]]];
}

- (void)optionsTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionPageTurn transitionWithDuration:0.5f scene:[Options scene]]];
}

- (void) dealloc { 
    [super dealloc]; 
} 

@end