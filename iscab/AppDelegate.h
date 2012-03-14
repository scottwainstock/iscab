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

#ifdef FREE_VERSION
#import "iAd/ADBannerView.h"
#endif

@class RootViewController;

#define NUM_JARS_TO_FILL 3
#define GAMEPLAY_SCENE_TAG 10
#define TRANSITION_SPEED 0.125f
#define ICON_TOUCH_AREA_SIZE 75

#ifdef FREE_VERSION
@interface AppDelegate : NSObject <UIApplicationDelegate, ADBannerViewDelegate> {
#else
@interface AppDelegate : NSObject <UIApplicationDelegate> {
#endif
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
    
    #ifdef FREE_VERSION
    ADBannerView *adView;
    #endif
}

@property(nonatomic) int screenWidth;
@property(nonatomic) int screenHeight;
@property(nonatomic, retain) NSUserDefaults *defaults;
@property(nonatomic, retain) UIWindow *window;
@property(nonatomic, retain) NSMutableArray *jars;
@property(nonatomic, retain) Scab *scab;
@property(nonatomic, retain) CCSpriteBatchNode *batchNode;
@property(nonatomic, retain) GameCenterBridge *gameCenterBridge;

    
#ifdef FREE_VERSION
@property(nonatomic, retain) ADBannerView *adView;
#endif
    
- (void)cleanupAndSave;
- (void)cacheLargeImages;
- (void)cleanupBatchNode;
- (void)saveState;
- (void)scheduleNotification:(NSDate *)date;
- (void)scheduleNotifications;
- (Jar *)currentJar;
- (void)createNewJars;

@end