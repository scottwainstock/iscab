//
//  Achievements.h
//  iscab
//
//  Created by Scott Wainstock on 12/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameKit/GameKit.h"
#import "IScabCCLayer.h"

@interface Achievements : IScabCCLayer <GKAchievementViewControllerDelegate> {
    UIViewController *viewController;
    GKAchievementViewController *achievementsViewController;
}

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) GKAchievementViewController *achievementsViewController;

+ (id)scene;

- (void)showAchievements;

@end