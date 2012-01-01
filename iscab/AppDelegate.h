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
#import "Scab.h"
#import "GameCenterBridge.h"

@class RootViewController;

#define NUM_JARS_TO_FILL 3
#define GAMEPLAY_SCENE_TAG 10
#define TRANSITION_SPEED 0.125f
#define ICON_TOUCH_AREA_SIZE 75

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    int screenWidth;
    int screenHeight;
	UIWindow *window;
    AVAudioPlayer *audioPlayer;
    NSMutableArray *jars;
    NSUserDefaults *defaults;
    Scab *scab;
    CCSpriteBatchNode *batchNode;
    GameCenterBridge *gameCenterBridge;
    RootViewController *viewController;
}

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic, retain) NSUserDefaults *defaults;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *jars;
@property (nonatomic, retain) Scab *scab;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) GameCenterBridge *gameCenterBridge;

- (void)saveState;
- (void)scheduleNotification:(NSDate *)date;
- (void)scheduleNotifications;
- (Jar *)currentJar;
- (void)createNewJars;

@end