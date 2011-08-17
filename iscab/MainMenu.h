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
}

+ (id)scene;

- (void)startPickinTapped:(CCMenuItem  *)menuItem;
- (void)jarTapped:(CCMenuItem *)menuItem;
- (void)helpTapped:(CCMenuItem *)menuItem;
- (void)optionsTapped:(CCMenuItem *)menuItem;

@end