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

@interface MainMenu : IScabCCLayer <UIAlertViewDelegate> {
    CCMenu *menu;
    CCMenu *iconMenu;
    CCMenuItem *aboutButton;
    CCMenuItem *jarButton;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCMenu *iconMenu;
@property (nonatomic, retain) CCMenuItem *aboutButton;
@property (nonatomic, retain) CCMenuItem *jarButton;

+ (id)scene;

- (void)startPickinTapped:(CCMenuItem  *)menuItem;
- (void)helpTapped:(CCMenuItem *)menuItem;
- (void)leaderboardsTapped:(CCMenuItem *)menuItem;
- (void)chooseSkinTapped:(CCMenuItem *)menuItem;
- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState;

@end