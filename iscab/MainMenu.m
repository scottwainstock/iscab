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

@synthesize menu, aboutButton, jarButton;

AppDelegate *app;

+ (id)scene {
    CCScene *scene = [CCScene node];
    MainMenu *layer = [MainMenu node];
    [scene addChild: layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        CCSprite *homeLogo = [CCSprite spriteWithFile:@"Home_Logo.png"];
        homeLogo.position = ccp(150, 300);
        [self addChild:homeLogo z:0];
       
        menu = [CCMenu menuWithItems:nil];        
        menu.position = ccp(160, 160);
                
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"StartPickin.png" selectedImage: @"StartPickin-Hover.png" target:self selector:@selector(startPickinTapped:)]];
        
        if ([app.defaults boolForKey:@"gameCenterEnabled"])
            [menu addChild:[CCMenuItemImage itemFromNormalImage:@"TopPickers.png" selectedImage: @"TopPickers-Hover.png" target:self selector:@selector(leaderboardsTapped:)]];    
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"ChooseSkin.png" selectedImage: @"ChooseSkin-Hover.png" target:self selector:@selector(chooseSkinTapped:)]];
        
        [menu addChild:[self currentSoundState:[app.defaults boolForKey:@"sound"]]];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"Help.png" selectedImage: @"Help-Hover.png" target:self selector:@selector(helpTapped:)]];

       
        [menu alignItemsVerticallyWithPadding:5.0f];
        [self addChild:menu];
        
        if ([app.defaults objectForKey:@"sendNotifications"] == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notifications" 
                                                            message:@"Do you want to allow iScab to send you local notifications?"
                                                           delegate:self
                                                  cancelButtonTitle:@"NO" 
                                                  otherButtonTitles:@"YES", nil];
            [alert show];
            [alert release];
        }        
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"YES"])
        [app.defaults setBool:YES forKey:@"sendNotifications"];
    else if ([title isEqualToString:@"NO"])
        [app.defaults setBool:NO forKey:@"sendNotifications"];
}

- (void)setupNavigationIcons {
    aboutButton = [CCMenuItemImage itemFromNormalImage:@"About.png" selectedImage:@"About-Hover.png" target:self selector:@selector(aboutTapped:)];
    aboutButton.position = ccp(40, 40);
    
    jarButton = [CCMenuItemImage itemFromNormalImage:@"jar.png" selectedImage:@"Jar-Hover.png" target:self selector:@selector(jarTapped:)];
    jarButton.position = ccp(280, 40);
    
    CCMenu *iconMenu = [CCMenu menuWithItems:aboutButton, jarButton, nil];
    iconMenu.position = CGPointZero;
    [self addChild:iconMenu z:2];
}

- (void)startPickinTapped:(CCMenuItem  *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[GamePlay scene]]];
}

- (void)helpTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[Help scene]]];
}

- (void)leaderboardsTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[Leaderboard scene]]];
}

- (void)chooseSkinTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SkinColorPicker scene]]];
}

- (void)soundTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [app.defaults setBool:[app.defaults boolForKey:@"sound"] ? FALSE : TRUE forKey:@"sound"];
    [app.defaults synchronize];
    
    [CDAudioManager sharedManager].mute = [app.defaults boolForKey:@"sound"];    
}

- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState {
    CCMenuItemImage *on = [[CCMenuItemImage itemFromNormalImage:@"SoundOn.png" selectedImage:@"SoundOn-Hover.png" target:nil selector:nil] retain];
    CCMenuItemImage *off = [[CCMenuItemImage itemFromNormalImage:@"SoundOff.png" selectedImage:@"SoundOff-Hover.png" target:nil selector:nil] retain];
    
    if (currentSoundState) {
        return [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:on, off, nil];
    } else {
        return [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:off, on, nil];
    }
}

- (void) dealloc { 
    [menu release];
    [aboutButton release];
    [jarButton release];
    [super dealloc];
} 

@end