//
//  OptionMenu.h
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "IScabCCMenuLayer.h"

@interface OptionMenu : IScabCCMenuLayer <UIAlertViewDelegate> {
}

+ (id)scene;

- (void)helpTapped:(CCMenuItem *)menuItem;
- (void)leaderboardsTapped:(CCMenuItem *)menuItem;
- (CCMenuItemToggle *)currentSoundState:(bool)currentSoundState;
- (CCMenuItemToggle *)currentTutorialState:(bool)currentTutorialState;

@end