//
//  MainMenu.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCMenuLayer.h"

@interface MainMenu : IScabCCMenuLayer <UIAlertViewDelegate> {
}

+ (id)scene;

- (void)startPickinTapped:(CCMenuItem  *)menuItem;
- (void)chooseSkinTapped:(CCMenuItem *)menuItem;
- (void)scabJarTapped:(CCMenuItem *)menuItem;
- (void)optionsTapped:(CCMenuItem *)menuItem;

@end