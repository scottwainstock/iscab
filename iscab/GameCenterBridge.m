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
    if (![app.defaults boolForKey:@"gameCenterEnabled"])
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
    if (![app.defaults boolForKey:@"gameCenterEnabled"])
        return;
    
    NSLog(@"CHEEVO: %@", identifier);

    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement) {
        [achievement setPercentComplete:100.0];
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
             if (error != nil) {
             }
         }];
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
    //[GKAchievement resetAchievementsWithCompletionHandler:nil];
    /*[self reportAchievementIdentifier:@"iscab_xxx"];
    [self reportAchievementIdentifier:@"iscab_jesus"];
    [self reportAchievementIdentifier:@"iscab_heart"];
    [self reportAchievementIdentifier:@"iscab_sass"];
    [self reportAchievementIdentifier:@"iscab_illuminati"];*/

    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error == nil)
            for (GKAchievement *achievement in achievements)
                [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }];
    
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error == nil) {           
            for (GKAchievementDescription *achievementDescription in descriptions)
                [achievementsDescriptionDictionary setObject:achievementDescription forKey:achievementDescription.identifier];
        }
    }];
}

- (void)dealloc {
    [achievementsDictionary release];
    [achievementsDescriptionDictionary release];
    [super dealloc];
}

@end