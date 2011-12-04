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
#import "AppDelegate.h"

@interface Leaderboard : IScabCCLayer <GKLeaderboardViewControllerDelegate> {
    GKLeaderboardViewController *leaderboardViewController;
    UIViewController *viewController;
}

@property (nonatomic, retain) GKLeaderboardViewController *leaderboardViewController;
@property (nonatomic, retain) UIViewController *viewController;

+ (id)scene;

- (void)showLeaderboard;

@end