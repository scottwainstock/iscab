//
//  Leaderboards.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCLayer.h"
#import "GameKit/GameKit.h"

@interface Leaderboard : IScabCCLayer <GKLeaderboardViewControllerDelegate> {
    UIViewController *leaderboardViewController;
}

@property (nonatomic, retain) UIViewController *leaderboardViewController;

+ (id)scene;

- (void)showLeaderboard;

@end