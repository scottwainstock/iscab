//
//  IScabCCMenuLayer.h
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CCMenuWideTouch.h"
#import "IScabCCLayer.h"

@interface IScabCCMenuLayer : IScabCCLayer {
    CCMenu *menu;
}

@property (nonatomic, retain) CCMenu *menu;

- (void)playMenuSound;
- (void)setupNavigationIcons;

@end