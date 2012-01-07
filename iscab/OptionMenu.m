//
//  OptionMenu.m
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionMenu.h"
#import "AppDelegate.h"
#import "Help.h"
#import "About.h"
#import "Leaderboard.h"
#import "Achievements.h"
#import "CDAudioManager.h"

@implementation OptionMenu

AppDelegate *app;

+ (id)scene {
    CCScene *scene = [CCScene node];
    OptionMenu *layer = [OptionMenu node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"StopPickin.png" selectedImage: @"StopPickin-Hover.png" target:self selector:@selector(stopTapped:)]];
        
        if ([app.defaults boolForKey:@"gameCenterEnabled"])
            [menu addChild:[CCMenuItemImage itemFromNormalImage:@"TopPickers.png" selectedImage: @"TopPickers-Hover.png" target:self selector:@selector(leaderboardsTapped:)]];    
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"Achievements.png" selectedImage: @"Achievements-Hover.png" target:self selector:@selector(achievementsTapped:)]];
        
        [menu addChild:[self currentTutorialState:[app.defaults boolForKey:@"tutorial"]]];
        [menu addChild:[self currentSoundState:[app.defaults boolForKey:@"sound"]]];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"About.png" selectedImage: @"About-Hover.png" target:self selector:@selector(aboutTapped:)]];
        
        [menu addChild:[CCMenuItemImage itemFromNormalImage:@"Help.png" selectedImage: @"Help-Hover.png" target:self selector:@selector(helpTapped:)]];
        
        [menu alignItemsVerticallyWithPadding:10.0f];
        [menu setPosition:ccp(160, 247)];
        [self addChild:menu];
    }
    
    return self;
}

- (void)aboutTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[About scene]]];
}

- (void)helpTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[Help scene]]];
}

- (void)leaderboardsTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[Leaderboard scene]]];
}

- (void)achievementsTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[Achievements scene]]];
}

- (void)soundTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [app.defaults setBool:[app.defaults boolForKey:@"sound"] ? FALSE : TRUE forKey:@"sound"];    
    [[CDAudioManager sharedManager] setMute:![app.defaults boolForKey:@"sound"]];    
}

- (void)tutorialTapped:(CCMenuItem *)menuItem {
    [super playMenuSound];
    
    [app.defaults setBool:[app.defaults boolForKey:@"tutorial"] ? FALSE : TRUE forKey:@"tutorial"];    
}

- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState {
    CCMenuItemImage *on = [[CCMenuItemImage itemFromNormalImage:@"SoundChecked.png" selectedImage:@"Sound-Hover.png" target:nil selector:nil] retain];
    CCMenuItemImage *off = [[CCMenuItemImage itemFromNormalImage:@"SoundBlank.png" selectedImage:@"Sound-Hover.png" target:nil selector:nil] retain];
    
    CCMenuItemToggle *toggle;
    if (currentSoundState)
        toggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:on, off, nil];
    else
        toggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(soundTapped:) items:off, on, nil];
    
    [on release];
    [off release];
    return toggle;
}

- (CCMenuItemToggle *)currentTutorialState:(bool)currentTutorialState {
    CCMenuItemImage *on = [[CCMenuItemImage itemFromNormalImage:@"TutorialChecked.png" selectedImage:@"Tutorial-Hover.png" target:nil selector:nil] retain];
    CCMenuItemImage *off = [[CCMenuItemImage itemFromNormalImage:@"TutorialBlank.png" selectedImage:@"Tutorial-Hover.png" target:nil selector:nil] retain];
    
    CCMenuItemToggle *toggle;
    if (currentTutorialState)
        toggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(tutorialTapped:) items:on, off, nil];
    else
        toggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(tutorialTapped:) items:off, on, nil];

    [on release];
    [off release];
    return toggle;
}

- (IBAction)stopTapped:(id)sender {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stop Pickin'" 
                                                    message:@"Are you sure you want to stop Pickin' and empty all jars and start all over?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO" 
                                          otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"YES"]) {
        [app.defaults setObject:nil forKey:@"numScabsPicked"];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [app createNewJars];
        [GKAchievement resetAchievementsWithCompletionHandler:nil];
        [app.gameCenterBridge resetAchievements];
        NSLog(@"STOP");
    }
}

@end