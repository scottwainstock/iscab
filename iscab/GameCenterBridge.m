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

@synthesize achievementsDictionary, achievementsDescriptionDictionary, unlockedAchievementsDescriptions;

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

+ (NSString *)massagedAchievementName:(NSString *)rawAchievementName {
    NSString *achievementPrefix = @"iscab";
    
    #ifdef FREE_VERSION
    achievementPrefix = @"iscab_free";
    #endif
    
    return [NSString stringWithFormat:@"%@_%@", achievementPrefix, rawAchievementName];
}

- (void)reportAchievements:(NSArray *)achievements {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ((![app.defaults boolForKey:@"gameCenterEnabled"]) || (![[GKLocalPlayer localPlayer] isAuthenticated]))
        return;
    
    unlockedAchievementsDescriptions = [[NSMutableArray alloc] init];
    for (NSString *identifier in achievements) {
        GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
        [achievement setPercentComplete:100.0];
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {}];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];        
    }
    
    if ([unlockedAchievementsDescriptions count]) {
        [[GKAchievementHandler defaultHandler] setImage:nil]; 
        
        for (NSString *message in unlockedAchievementsDescriptions)
            [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Achievement Unlocked!" andMessage:message];
    }
}

- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier {
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    
    if (achievement == nil) {
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        GKAchievementDescription *description = [achievementsDescriptionDictionary objectForKey:identifier];
        [unlockedAchievementsDescriptions addObject:[description title]];
    }
        
    return achievement;
}

- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil)
            [self loadAchievements];
    }];
}

- (void)loadAchievements {
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
}

- (void)reportAchievementsForScab:(Scab *)scab {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *achievementsUnlocked = [[NSMutableArray alloc] init];
    
    [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"power"]];

    if ([app.currentJar numScabLevels] >= MAX_NUM_SCAB_LEVELS)   
        if ([[NSDate date] timeIntervalSinceDate:[app.defaults objectForKey:@"jarStartTime"]] <= SPEEDILY_FILLED_JAR_TIME)
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"speedjar"]];
    
    if (!scab.isOverpickWarningIssued)
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"surgeon"]];
    
    if (![scab.name isEqualToString:@"standard"])
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:scab.name]];
    
    if ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= SCAB_GOOD_TIME)
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"goodtime"]];
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_GOOD_TIME)
    )
        if ([self.achievementsDictionary objectForKey:[GameCenterBridge massagedAchievementName:@"biggood"]])
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"biggoodagain"]];
        else
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"biggood"]];
    
    if ((scab.scabSize == XL_SCAB) && ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_MIN_TIME)) {
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"bigmin"]];
        
        int numBigScabsPickedInMinimumTime = [[app.defaults objectForKey:[GameCenterBridge massagedAchievementName:@"3big"]] intValue];
        numBigScabsPickedInMinimumTime += 1;
        
        if (numBigScabsPickedInMinimumTime >= 3)
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"3big"]];
        
        [app.defaults setObject:[NSNumber numberWithInt:numBigScabsPickedInMinimumTime] forKey:[GameCenterBridge massagedAchievementName:@"3big"]];
    }
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_QUICKLY)
    )
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"bigquick"]];
    
    if ([scab.name isEqualToString:@"standard"] && scab.scabSize == SMALL_SCAB)
        if ([self.achievementsDictionary objectForKey:[GameCenterBridge massagedAchievementName:@"pity"]])
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"pityagain"]];
        else
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"pity"]];
    
    bool allSpecialScabsPicked = true;
    for (NSString *specialScabName in [SpecialScabs specialScabNames])
        if ([self.achievementsDictionary objectForKey:[GameCenterBridge massagedAchievementName:specialScabName]] == nil)
            allSpecialScabsPicked = false;
    
    if (allSpecialScabsPicked)
        [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"allspecial"]];
    
    int jarsFilled = 0;
    for (Jar *jar in app.jars)
        if ([jar numScabLevels] == MAX_NUM_SCAB_LEVELS)
            jarsFilled += 1;
 
    switch (jarsFilled) {
        case 1:
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"1filled"]];
            break;
        case 2:
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"2filled"]];
            break;
        case 3:
            if (![app.defaults boolForKey:@"score_reported"]) {
                NSString *leaderboard = @"iscab_leaderboard";
                
                #ifdef FREE_VERSION
                    leaderboard = @"iscab_free_leaderboard";
                #endif
                
                [GameCenterBridge reportScore:[[NSDate date] timeIntervalSinceDate:[app.defaults objectForKey:@"gameStartTime"]] forCategory:leaderboard];
                [app.defaults setBool:YES forKey:@"score_reported"];
            }
            
            [achievementsUnlocked addObject:[GameCenterBridge massagedAchievementName:@"3filled"]];
            break;
        default:
            break;
    }
    
    [self reportAchievements:achievementsUnlocked];
    [achievementsUnlocked release];
}

- (void)dealloc {
    [unlockedAchievementsDescriptions release];
    [achievementsDictionary release];
    [achievementsDescriptionDictionary release];
    [super dealloc];
}

@end