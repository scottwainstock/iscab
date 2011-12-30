//
//  GameCenterBridge.m
//  iscab
//
//  Created by Scott Wainstock on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCenterBridge.h"
#import "SpecialScabs.h"
#import "AppDelegate.h"
#import "GKAchievementHandler.h"
#import "GameKit/GameKit.h"

@implementation GameCenterBridge

@synthesize achievementsDictionary, achievementsDescriptionDictionary;

- (id)init {
    if ((self = [super init])) {
        achievementsDictionary = [[NSMutableDictionary alloc] init];
        achievementsDescriptionDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (void)reportScore:(int64_t)score forCategory:(NSString*)category {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ((![app.defaults boolForKey:@"gameCenterEnabled"]) || (![[GKLocalPlayer localPlayer] isAuthenticated]))
        return;
    
    NSLog(@"ABOUT TO REPORT %lld", score);
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
            [app.defaults setObject:[NSNumber numberWithLongLong:score] forKey:@"highScore"];
    }];
}

+ (BOOL)isGameCenterAPIAvailable {
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

- (void)reportAchievementIdentifier:(NSString*)identifier {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ((![app.defaults boolForKey:@"gameCenterEnabled"]) || (![[GKLocalPlayer localPlayer] isAuthenticated]))
        return;
    
    NSLog(@"CHEEVO: %@", identifier);

    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement) {
        [achievement setPercentComplete:100.0];
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {}];
    }    
}

- (GKAchievement*)getAchievementForIdentifier:(NSString*)identifier {
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    
    if (achievement == nil) {
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
        
        GKAchievementDescription *description = [achievementsDescriptionDictionary objectForKey:identifier];
        [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Achievement Unlocked!" andMessage:[description title]];
    }
    
    return [[achievement retain] autorelease];
}

- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil)
            [self loadAchievements];
    }];
}

- (void)loadAchievements {
    /*[self reportAchievementIdentifier:@"iscab_xxx"];
    [self reportAchievementIdentifier:@"iscab_jesus"];
    [self reportAchievementIdentifier:@"iscab_heart"];
    [self reportAchievementIdentifier:@"iscab_sass"];
    [self reportAchievementIdentifier:@"iscab_illuminati"];*/
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error == nil)
            for (GKAchievement *achievement in achievements) {
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
                [achievement setPercentComplete:100.0];
                [achievement reportAchievementWithCompletionHandler:^(NSError *error) {}];
            }
    }];
    
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error == nil)          
            for (GKAchievementDescription *achievementDescription in descriptions)
                [achievementsDescriptionDictionary setObject:achievementDescription forKey:achievementDescription.identifier];
    }];
}

- (void)resetAchievements {
    [achievementsDictionary removeAllObjects];
    [achievementsDescriptionDictionary removeAllObjects];
}

- (void)reportAchievementsForScab:(Scab *)scab {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if (!scab.isOverpickWarningIssued)
        [self reportAchievementIdentifier:@"iscab_surgeon"];
    
    if (![scab.name isEqualToString:@"standard"])
        [self reportAchievementIdentifier:[NSString stringWithFormat:@"iscab_%@", scab.name]];
    
    if ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= SCAB_GOOD_TIME)
        [self reportAchievementIdentifier:@"iscab_goodtime"];
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_GOOD_TIME)
        ) {
        if ([self.achievementsDictionary objectForKey:@"iscab_biggood"])
            [self reportAchievementIdentifier:@"iscab_biggoodagain"];
        else
            [self reportAchievementIdentifier:@"iscab_biggood"];
    }
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_MIN_TIME)
        ) {
        [self reportAchievementIdentifier:@"iscab_bigmin"];
        
        int numBigScabsPickedInMinimumTime = [[app.defaults objectForKey:@"iscab_3big"] intValue];
        numBigScabsPickedInMinimumTime += 1;
        
        if (numBigScabsPickedInMinimumTime >= 3)
            [self reportAchievementIdentifier:@"iscab_3big"];
        
        [app.defaults setObject:[NSNumber numberWithInt:numBigScabsPickedInMinimumTime] forKey:@"iscab_3big"];
    }
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_QUICKLY)
        )
        [self reportAchievementIdentifier:@"iscab_bigquick"];
    
    if ([scab.name isEqualToString:@"standard"] && scab.scabSize == SMALL_SCAB) {
        if ([self.achievementsDictionary objectForKey:@"iscab_pityscab"])
            [self reportAchievementIdentifier:@"iscab_pityagain"];
        else
            [self reportAchievementIdentifier:@"iscab_pity"];
    }
    
    bool allSpecialScabsPicked = true;
    for (NSString *specialScabName in [SpecialScabs specialScabNames]) {
        if ([self.achievementsDictionary objectForKey:specialScabName] == nil)
            allSpecialScabsPicked = false;
    }
    
    if (allSpecialScabsPicked)
        [self reportAchievementIdentifier:@"iscab_allspecial"];
    
    int jarsFilled = 0;
    for (Jar *jar in app.jars)
        if ([jar numScabLevels] == MAX_NUM_SCAB_LEVELS)
            jarsFilled += 1;
    
    switch (jarsFilled) {
        case 1:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_1filled"];
            break;
        case 2:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_2filled"];
            break;
        case 3:
            [GameCenterBridge reportScore:[[NSDate date] timeIntervalSinceDate:[app.defaults objectForKey:@"gameStartTime"]] forCategory:@"iscab_leaderboard"];
            [self reportAchievementIdentifier:@"iscab_3filled"];
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [achievementsDictionary release];
    [achievementsDescriptionDictionary release];
    [super dealloc];
}

@end