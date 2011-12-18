//
//  Achievements.m
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Achievements.h"
#import "AppDelegate.h"

@implementation Achievements

@synthesize viewController, achievementsViewController;

+ (id)scene {
    CCScene *scene = [CCScene node];
    Achievements *layer = [Achievements node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if ((self = [super init]))
        [self showAchievements];
    
    return self;
}

- (void)showAchievements {
    viewController = [[UIViewController alloc] init]; 
    [[[[CCDirector sharedDirector] openGLView] window] addSubview:viewController.view];
    
    achievementsViewController = [[GKAchievementViewController alloc] init];
    if (achievementsViewController != nil) {
        [achievementsViewController setAchievementDelegate:self];
        [viewController presentModalViewController:achievementsViewController animated:YES];
    }
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)achievementsViewController {
    [viewController dismissModalViewControllerAnimated:NO];
    [viewController.view removeFromSuperview];
    
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionCrossFade class] duration:TRANSITION_SPEED];
}

- (void)dealloc {
    [viewController release];
    [achievementsViewController release];
    [super dealloc];
}

@end