//
//  MainMenu.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCLayer.h"

@interface MainMenu : IScabCCLayer {
    CCMenuItemToggle *sound;
    CCMenuItem *start;
    CCMenuItem *leaderboard;
    CCMenuItem *chooseSkin;
    CCMenuItem *help; 
    CCMenu *menu;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCMenuItem *start;
@property (nonatomic, retain) CCMenuItem *leaderboard;
@property (nonatomic, retain) CCMenuItem *chooseSkin;
@property (nonatomic, retain) CCMenuItem *help;
@property (nonatomic, retain) CCMenuItemToggle *sound;

+ (id)scene;

- (void)startPickinTapped:(CCMenuItem  *)menuItem;
- (void)helpTapped:(CCMenuItem *)menuItem;
- (void)leaderboardsTapped:(CCMenuItem *)menuItem;
- (void)chooseSkinTapped:(CCMenuItem *)menuItem;
- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState;

@end