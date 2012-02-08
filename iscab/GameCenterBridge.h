//
//  GameCenterBridge.h
//  iscab
//
//  Created by Scott Wainstock on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#import "Scab.h"

#define SPEEDILY_FILLED_JAR_TIME 3600 * 2
#define BIG_SCAB_GOOD_TIME 240 * 4
#define BIG_SCAB_QUICKLY 240 * 3
#define BIG_SCAB_MIN_TIME 240 * 2
#define SCAB_GOOD_TIME 120 * 2

@interface GameCenterBridge : NSObject {
    NSMutableDictionary *achievementsDictionary;
    NSMutableDictionary *achievementsDescriptionDictionary;
    NSMutableArray *unlockedAchievementsDescriptions;
}

@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;
@property(nonatomic, retain) NSMutableDictionary *achievementsDescriptionDictionary;
@property(nonatomic, retain) NSMutableArray *unlockedAchievementsDescriptions;

+ (void)reportScore:(int64_t)score forCategory:(NSString *)category;
+ (BOOL)isGameCenterAPIAvailable;

- (void)reportAchievements:(NSArray *)achievements;
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;
- (void)authenticateLocalPlayer;
- (void)loadAchievements;
- (void)resetAchievements;
- (void)reportAchievementsForScab:(Scab *)scab;

@end