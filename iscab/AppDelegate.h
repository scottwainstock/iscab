//
//  AppDelegate.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Jar.h"
#import "GameCenterBridge.h"

@class RootViewController;

#define NUM_JARS_TO_FILL 3
#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10
#define GAMEPLAY_SCENE_TAG 10
#define TRANSITION_SPEED 0.25f

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	RootViewController *viewController;
    AVAudioPlayer *audioPlayer;
    NSMutableArray *jars;
    int screenWidth;
    int screenHeight;
    CCSpriteBatchNode *batchNode;
    NSMutableArray *scabs;
    CCMenuItem *backButton;
    CCMenuItem *jarButton;
    GameCenterBridge *gameCenterBridge;
    NSUserDefaults *defaults;
}

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic, retain) NSUserDefaults *defaults;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *jars;
@property (nonatomic, retain) NSMutableArray *scabs;
@property (nonatomic, retain) CCMenuItem *backButton;
@property (nonatomic, retain) CCMenuItem *jarButton;
@property (nonatomic, retain) GameCenterBridge *gameCenterBridge;

- (Jar *)currentJar;
- (CGPoint)centerOfAllScabs;
- (void)saveState;
- (void)scheduleNotification:(NSDate *)date;
- (void)scheduleNotifications;

@end