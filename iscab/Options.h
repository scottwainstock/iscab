//
//  Options.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCLayer.h"

@interface Options : IScabCCLayer {
    CCMenuItemFont *soundMenuText;
}

@property (assign) CCMenuItemFont *soundMenuText;

+ (id)scene;

- (void)stopPickingTapped:(CCMenuItem  *)menuItem;
- (void)leaderboardsTapped:(CCMenuItem *)menuItem;
- (void)chooseSkinTapped:(CCMenuItem *)menuItem;
- (void)aboutTapped:(CCMenuItem *)menuItem;
- (void)soundTapped:(CCMenuItem *)menuItem;

@end