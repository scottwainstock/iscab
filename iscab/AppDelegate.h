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

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    AVAudioPlayer       *audioPlayer;
    NSMutableArray *allScabs;
    NSMutableArray *allWounds;    
}

- (void)saveState;
- (void)removeScab:(ScabChunk *)scab initing:(bool)initing;

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *allScabs;
@property (nonatomic, retain) NSMutableArray *allWounds;

@end
