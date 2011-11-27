//
//  Leaderboards.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Leaderboard.h"
#import "GameKit/GKLeaderboardViewController.h"

@implementation Leaderboard

@synthesize viewController, leaderboardViewController;

+ (id)scene {
    CCScene *scene = [CCScene node];
    Leaderboard *layer = [Leaderboard node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if ((self=[super init]))
        [self showLeaderboard];
    
    return self;
}

- (void)showLeaderboard {
    viewController = [[UIViewController alloc] init]; 
    [[[[CCDirector sharedDirector] openGLView] window] addSubview:viewController.view];
    
    leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardViewController != nil) {
        leaderboardViewController.leaderboardDelegate = self;
        [viewController presentModalViewController:leaderboardViewController animated:YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)leaderBoardViewController {
    [viewController dismissModalViewControllerAnimated:NO];
    [viewController.view removeFromSuperview];

    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionCrossFade class] duration:TRANSITION_SPEED];
}

- (void)dealloc {
    [viewController release];
    [leaderboardViewController release];
    [super dealloc];
}

@end