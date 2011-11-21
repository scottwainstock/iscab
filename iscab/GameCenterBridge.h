//
//  GameCenterBridge.h
//  iscab
//
//  Created by Scott Wainstock on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"

#define SPEEDILY_FILLED_JAR_TIME 3600
#define BIG_SCAB_GOOD_TIME 200
#define SCAB_GOOD_TIME 120

@interface GameCenterBridge : NSObject {
    NSMutableDictionary *achievementsDictionary;
}

@property (nonatomic, retain) NSMutableDictionary *achievementsDictionary;

+ (void)reportScore:(int64_t)score forCategory:(NSString *)category;
+ (BOOL)isGameCenterAPIAvailable;
- (void)reportAchievementIdentifier:(NSString *)identifier;
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;
- (void)authenticateLocalPlayer;
- (void)loadAchievements;

@end