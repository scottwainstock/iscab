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

@class RootViewController;

#define NUM_JARS_TO_FILL 3
#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	RootViewController *viewController;
    AVAudioPlayer *audioPlayer;
    NSMutableArray *jars;
    int screenWidth;
    int screenHeight;
    CCSpriteBatchNode *batchNode;
    NSMutableArray *scabs;
    NSMutableString *skinBackground;
    CCMenuItem *homeButton;
    CCMenuItem *jarButton;
}

@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;
@property (nonatomic, assign) NSMutableString *skinBackground;
@property (nonatomic, retain) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *jars;
@property (nonatomic, retain) NSMutableArray *scabs;
@property (nonatomic, retain) CCMenuItem *homeButton;
@property (nonatomic, retain) CCMenuItem *jarButton;

- (void)saveState;
- (Jar *)getCurrentJar;

@end