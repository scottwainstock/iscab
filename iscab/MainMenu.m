//
//  MainMenu.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "GamePlay.h"
#import "Help.h"
#import "JarScene.h"
#import "Leaderboard.h"
#import "SkinColorPicker.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

@implementation MainMenu

@synthesize menu, start, leaderboard, chooseSkin, sound, help;

+(id) scene {
    CCScene *scene = [CCScene node];
    MainMenu *layer = [MainMenu node];
    [scene addChild: layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"menu-background.png"];
        bg.anchorPoint = ccp(0, 0);
        bg.position = ccp(0, 0);
        [self addChild:bg z:0];
        
        start = [CCMenuItemImage itemFromNormalImage:@"StartPickin.png" selectedImage: @"StartPickin-Hover.png" target:self selector:@selector(startPickinTapped:)];
        
        leaderboard = [CCMenuItemImage itemFromNormalImage:@"TopPickers.png" selectedImage: @"TopPickers-Hover.png" target:self selector:@selector(leaderboardsTapped:)];
        
        chooseSkin = [CCMenuItemImage itemFromNormalImage:@"ChooseSkin.png" selectedImage: @"ChooseSkin-Hover.png" target:self selector:@selector(chooseSkinTapped:)];
        
        sound = [self currentSoundState:[defaults boolForKey:@"sound"]];
        
        help = [CCMenuItemImage itemFromNormalImage:@"Help.png" selectedImage: @"Help-Hover.png" target:self selector:@selector(helpTapped:)];

        menu = [CCMenu menuWithItems:start, leaderboard, chooseSkin, sound, help, nil];       
        menu.position = ccp(160, 160);
        [menu alignItemsVerticallyWithPadding:5.0];
        [self addChild:menu];        
    }
    
    return self;
}

- (void)setupNavigationIcons {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    CCMenuItem *aboutButton = [CCMenuItemImage itemFromNormalImage:@"About.png" selectedImage:@"About-Hover.png" target:self selector:@selector(aboutTapped:)];
    aboutButton.position = ccp(40, 40);
    
    app.jarButton = [CCMenuItemImage itemFromNormalImage:@"jar.png" selectedImage:@"Jar-Hover.png" target:self selector:@selector(jarTapped:)];
    app.jarButton.position = ccp(280, 40);
    
    CCMenu *iconMenu = [CCMenu menuWithItems:aboutButton, app.jarButton, nil];
    iconMenu.position = CGPointZero;
    [self addChild:iconMenu z:2];
}

- (void)startPickinTapped:(CCMenuItem  *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionFade transitionWithDuration:0.5f scene:[GamePlay scene]]];
}

- (void)helpTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionShrinkGrow transitionWithDuration:0.5f scene:[Help scene]]];
}

- (void)leaderboardsTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionPageTurn transitionWithDuration:0.5f scene:[Leaderboard scene]]];
}

- (void)chooseSkinTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionPageTurn transitionWithDuration:0.5f scene:[SkinColorPicker scene]]];
}

- (void)soundTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setBool:[defaults boolForKey:@"sound"] ? FALSE : TRUE forKey:@"sound"];
    [defaults synchronize];
    
    [CDAudioManager sharedManager].mute = [defaults boolForKey:@"sound"];    
}

- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState {
    CCMenuItemImage *on = [[CCMenuItemImage itemFromNormalImage:@"SOUND On.png" selectedImage:@"SOUND ON-Hover.png" target:nil selector:nil] retain];
    CCMenuItemImage *off = [[CCMenuItemImage itemFromNormalImage:@"SOUND OFF.png" selectedImage:@"SOUND OFF-Hover.png" target:nil selector:nil] retain];
    
    if (currentSoundState) {
        return [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:on, off, nil];
    } else {
        return [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:off, on, nil];
    }
}

- (void) dealloc { 
    [super dealloc];
    /*
    [start release];
    [leaderboard release];
    [chooseSkin release];
    [sound release];
    [help release];  */     
} 

@end