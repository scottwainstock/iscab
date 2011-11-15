//
//  Leaderboards.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Leaderboard.h"
#import "AppDelegate.h"
#import "CCUIViewWrapper.h"
#import "GameKit/GKLeaderboardViewController.h"

@implementation Leaderboard

@synthesize leaderboardViewController;

+ (id)scene {
    CCScene *scene = [CCScene node];
    Leaderboard *layer = [Leaderboard node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    leaderboardViewController = [[UIViewController alloc] init];        
    [leaderboardViewController presentModalViewController:leaderboardViewController animated:YES];
    
    CCUIViewWrapper *wrapper = [CCUIViewWrapper wrapperForUIView:leaderboardViewController.view];
    wrapper.contentSize = CGSizeMake(app.screenWidth, app.screenHeight);
    wrapper.position = ccp(app.screenWidth / 2, app.screenHeight / 2);
    [self addChild:wrapper];
    
    [self showLeaderboard];
    
    return self;
}

- (void)showLeaderboard {
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [leaderboardViewController presentModalViewController:leaderboardController animated: YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [leaderboardViewController dismissModalViewControllerAnimated:YES];
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionCrossFade class] duration:0.5f];
}

- (void)dealloc {
    [super dealloc];
    [leaderboardViewController release];
}

@end