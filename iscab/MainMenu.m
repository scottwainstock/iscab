//
//  MainMenu.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "GamePlay.h"
#import "AppDelegate.h"
#import "SkinColorPicker.h"
#import "JarScene.h"
#import "OptionMenu.h"
#import "SimpleAudioEngine.h"

@implementation MainMenu

AppDelegate *app;

+ (id)scene {
    CCScene *scene = [CCScene node];
    MainMenu *layer = [MainMenu node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;

        CCSprite *homeLogo = [CCSprite spriteWithFile:@"Home_Logo.png"];
        [homeLogo setPosition:ccp(155, 310)];
        [self addChild:homeLogo z:0];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"StartPickin.png" selectedImage: @"StartPickin-Hover.png" target:self selector:@selector(startPickinTapped:)]];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"ChooseSkin.png" selectedImage: @"ChooseSkin-Hover.png" target:self selector:@selector(chooseSkinTapped:)]];

        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"ScabJar.png" selectedImage: @"ScabJar-Hover.png" target:self selector:@selector(scabJarTapped:)]];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"Options.png" selectedImage: @"Options-Hover.png" target:self selector:@selector(optionsTapped:)]];
        
        [menu setPosition:ccp(160, 145)];
        [menu alignItemsVerticallyWithPadding:10.0f];
        [self addChild:menu];
    }
    
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    [app.defaults setBool:[title isEqualToString:@"YES"] forKey:@"sendNotifications"];
}

- (void)onEnter {
    NSLog(@"CURRENT NOTIFICATION STATUS: %@", [app.defaults objectForKey:@"sendNotifications"]);
    if ([app.defaults objectForKey:@"sendNotifications"] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notifications" 
                                                        message:@"Do you want to allow iScab to send you local notifications?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO" 
                                              otherButtonTitles:@"YES", nil];
        [alert show];
        [alert release];
    }        
    
    [super onEnter];
}

- (void)setupNavigationIcons {}

- (void)startPickinTapped:(CCMenuItem  *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[GamePlay scene]]];
}

- (void)chooseSkinTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SkinColorPicker scene]]];
}

- (void)scabJarTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[JarScene scene]]];    
}

- (void)optionsTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
        
    [[CCDirector sharedDirector] pushScene:[CCTransitionSlideInR transitionWithDuration:TRANSITION_SPEED scene:[OptionMenu scene]]];    
}

@end