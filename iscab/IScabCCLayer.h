//
//  IScabCCLayer.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCMenuWideTouch.h"

#define SKIN_BACKGROUND_TAG 8

@interface IScabCCLayer : CCLayer {
    CCMenuWideTouch *iconMenu;
    CCMenuItem *backButton;
    CCMenuItem *jarButton;
}

@property (nonatomic, retain) CCMenuWideTouch *iconMenu;
@property (nonatomic, retain) CCMenuItem *backButton;
@property (nonatomic, retain) CCMenuItem *jarButton;

- (void)setupBackground;
- (void)setupNavigationIcons;
- (void)backTapped:(CCMenuItem*)menuItem;
- (void)jarTapped:(CCMenuItem*)menuItem;

@end