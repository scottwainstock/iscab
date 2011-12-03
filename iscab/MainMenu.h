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
    CCMenuItem *aboutButton;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCMenuItem *aboutButton;

+ (id)scene;

- (void)startPickinTapped:(CCMenuItem  *)menuItem;
- (void)helpTapped:(CCMenuItem *)menuItem;
- (void)leaderboardsTapped:(CCMenuItem *)menuItem;
- (void)chooseSkinTapped:(CCMenuItem *)menuItem;
- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState;

@end