//
//  IScabCCLayer.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface IScabCCLayer : CCLayer {
}

- (void)setupNavigationIcons;
- (void)aboutTapped:(CCMenuItem*)menuItem;
- (void)backTapped:(CCMenuItem*)menuItem;
- (void)homeTapped:(CCMenuItem*)menuItem;
- (void)jarTapped:(CCMenuItem*)menuItem;
- (void)playMenuSound;

@end