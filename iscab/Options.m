//
//  Options.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Options.h"
#import "About.h"
#import "Leaderboard.h"
#import "SkinColorPicker.h"
#import "SimpleAudioEngine.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation Options

@synthesize soundMenuText;

+ (id)scene {
    CCScene *scene = [CCScene node];
    Options *layer = [Options node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        [CCMenuItemFont setFontName:DEFAULT_FONT_NAME];
        [CCMenuItemFont setFontSize:DEFAULT_FONT_SIZE];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"button.wav"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentSoundState = [defaults boolForKey:@"sound"] ? @"OFF" : @"ON";
        
        soundMenuText = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"SOUND %@", currentSoundState] target:self selector:@selector(soundTapped:)];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"OPTIONS" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 2];
        title.position =  ccp(160, 420);
        [self addChild: title];
        
        CCMenuItem *stopPicking = [CCMenuItemFont itemFromString:@"STOP PICKIN'" target:self selector:@selector(stopPickingTapped:)];
        CCMenuItem *leaderboards = [CCMenuItemFont itemFromString:@"LEADERBOARDS" target:self selector:@selector(leaderboardsTapped:)];
        CCMenuItem *chooseSkin = [CCMenuItemFont itemFromString:@"CHOOSE SKIN" target:self selector:@selector(chooseSkinTapped:)];
        CCMenuItem *about = [CCMenuItemFont itemFromString:@"ABOUT" target:self selector:@selector(aboutTapped:)];
        CCMenuItem *sound = soundMenuText;
        
        CCMenu *menu = [CCMenu menuWithItems:stopPicking,leaderboards,chooseSkin,about,sound,nil];
        
        menu.position = ccp(160, 200);
        [menu alignItemsVerticallyWithPadding:30.0];
        [self addChild:menu];
    }
    return self;
}

- (void)stopPickingTapped:(CCMenuItem  *)menuItem {
    [self playMenuSound];

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)leaderboardsTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionMoveInB transitionWithDuration:0.5f scene:[Leaderboard scene]]];
}

- (void)chooseSkinTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionFadeTR transitionWithDuration:0.5f scene:[SkinColorPicker scene]]];
}

- (void)aboutTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    [[CCDirector sharedDirector] pushScene:
	 [CCTransitionFlipX transitionWithDuration:0.5f scene:[About scene]]];
}

- (void)soundTapped:(CCMenuItem *)menuItem {
    [self playMenuSound];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentSoundState = [defaults boolForKey:@"sound"] ? @"OFF" : @"ON";
        
    [defaults setBool:[defaults boolForKey:@"sound"] ? FALSE : TRUE forKey:@"sound"];
    [defaults synchronize];
    
    [CDAudioManager sharedManager].mute = [defaults boolForKey:@"sound"];
        
    [soundMenuText setString:[NSString stringWithFormat:@"SOUND %@", [defaults boolForKey:@"sound"] ? @"OFF" : @"ON"]]; 

    [currentSoundState release];
}

@end