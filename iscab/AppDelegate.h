//
//  AppDelegate.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ScabChunk.h"
#import "Jar.h"

@class RootViewController;

#define NUM_JARS_TO_FILL 3

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow		   *window;
	RootViewController *viewController;
    AVAudioPlayer      *audioPlayer;
    NSMutableArray     *jars;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *jars;

- (void)saveState;
- (Jar *)getCurrentJar;

@end