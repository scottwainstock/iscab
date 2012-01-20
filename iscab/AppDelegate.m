//
//  AppDelegate.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "MainMenu.h"
#import "RootViewController.h"
#import "SimpleAudioEngine.h"
#import "GamePlay.h"
#import "Wound.h"
#import "chipmunk.h"
#import "GameKit/GameKit.h"
#import "IScabSprite.h"

@implementation AppDelegate

@synthesize window, jars, screenWidth, screenHeight, batchNode, scab, gameCenterBridge, defaults;

- (NSMutableArray *)jars { 
    @synchronized(jars) {
        if (jars == nil)
            jars = [[NSMutableArray alloc] init];
        return jars;
    }
    return nil;
}

- (CCSpriteBatchNode *)batchNode {    
    @synchronized(batchNode) {
        if (batchNode == nil)
            batchNode = [[CCSpriteBatchNode alloc] init];
        
        return batchNode;
    }
    return nil;
}

- (void)removeStartupFlicker {
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
    NSLog(@"STARTING APPLICATION DID FINISH LAUNCHING");
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if(![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if(![director enableRetinaDisplay:YES])
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
//#else
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
//#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    if ([GameCenterBridge isGameCenterAPIAvailable]) {
        [self.defaults setBool:YES forKey:@"gameCenterEnabled"];
        gameCenterBridge = [[GameCenterBridge alloc] init];
        [self.gameCenterBridge authenticateLocalPlayer];
    } else {
        [self.defaults setBool:NO forKey:@"gameCenterEnabled"];
    }

    if ([self.defaults objectForKey:@"highScore"]) {
        [GameCenterBridge reportScore:[[self.defaults objectForKey:@"highScore"] longLongValue] forCategory:@"iscab_leaderboard"];
        [self.defaults removeObjectForKey:@"highScore"];
    }

    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scabs.plist"];
        
    if ([self.defaults stringForKey:@"skinColor"] == NULL)
        [self.defaults setObject:@"light" forKey:@"skinColor"];

    if ([self.defaults stringForKey:@"sound"] == NULL)
        [self.defaults setBool:TRUE forKey:@"sound"];
    
    if ([self.defaults stringForKey:@"tutorial"] == NULL)
        [self.defaults setBool:TRUE forKey:@"tutorial"];
        
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.1];
    [[CDAudioManager sharedManager] setMute:![self.defaults boolForKey:@"sound"]];    

    cpInitChipmunk();
            
    NSData *mJars = [self.defaults objectForKey:@"jars"];
    if (mJars != nil) {
        NSLog(@"LOADING SAVED JARS");
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mJars];
        if (oldSavedArray != nil) {                
            for (Jar *savedJar in oldSavedArray) {
                Jar *jar = [[Jar alloc] initWithNumScabLevels:savedJar.numScabLevels];
                                
                [self.jars addObject:jar];
                [jar release];
            }
        }
    } else {
        [self createNewJars];
    }
    
    //call each possible menu background so they are cached when you select them in skin picking screen
    [CCSprite spriteWithFile:[NSString stringWithFormat:@"light_skin_background2.jpg"]];
    [CCSprite spriteWithFile:[NSString stringWithFormat:@"medium_skin_background2.jpg"]];
    [CCSprite spriteWithFile:[NSString stringWithFormat:@"dark_skin_background2.jpg"]];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
    
    [[CCDirector sharedDirector] runWithScene:[MainMenu scene]];
}

- (void)createNewJars {
    NSLog(@"CREATING NEW JARS");
    self.jars = nil;
    for (int i = 0; i < NUM_JARS_TO_FILL; i++) {
        Jar *jar = [[Jar alloc] initWithNumScabLevels:0];
        [self.jars addObject:jar];
        
        [jar release];
    }
    
    [self.defaults setObject:[NSDate date] forKey:@"gameStartTime"];
    [self.defaults setObject:[NSDate date] forKey:@"jarStartTime"]; 
}

- (Jar *)currentJar {
    for (Jar *jar in self.jars)
        if (jar.numScabLevels > 0 && jar.numScabLevels < MAX_NUM_SCAB_LEVELS)
            return jar;
    
    for (Jar *jar in self.jars)
        if (jar.numScabLevels < MAX_NUM_SCAB_LEVELS)
            return jar;
    
    return [self.jars objectAtIndex:0];
}

- (void)scheduleNotification:(NSDate *)date {
    if (![defaults boolForKey:@"sendNotifications"])    
        return;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setFireDate:date];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setAlertBody:@"You've got an itchy scab."];
    [notification setAlertAction:@"Take me to it."];
    [notification setSoundName:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [notification release];
    
    NSLog(@"NOTIFICATION SCHEDULED FOR: %@", date);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"RECEIVED LOCAL NOTIFICATION");
    
    if (
        application.applicationState == UIApplicationStateInactive && 
        [[CCDirector sharedDirector] runningScene].tag != GAMEPLAY_SCENE_TAG
    )
        [[CCDirector sharedDirector] pushScene:[GamePlay scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
    
    if ([[CCDirector sharedDirector] runningScene].tag == GAMEPLAY_SCENE_TAG)
        [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:GAMEPLAY_SCENE_TAG] displayExistingBoard];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
    NSLog(@"DID ENTER BACKGROUND");
	[[CCDirector sharedDirector] stopAnimation];

    [self scheduleNotifications];
    
    if ([[CCDirector sharedDirector] runningScene].tag == GAMEPLAY_SCENE_TAG) {
        NSLog(@"CLEANING UP SCENE FROM APP DELEGATE");
        [self cleanupBatchNode];
        [self saveState];
        [self.scab reset];
        
        [[[CCDirector sharedDirector] runningScene] removeChild:self.batchNode cleanup:YES];
    }
}

- (void)cleanupBatchNode {
    NSMutableArray *removedSprites = [[NSMutableArray alloc] init];
    for (IScabSprite *sprite in [self.batchNode children])
        [removedSprites addObject:sprite];
    
    for (ScabChunk *sprite in removedSprites)
        [self.batchNode removeChild:sprite cleanup:YES];
    
    [removedSprites release];
}

- (void)scheduleNotifications {
    if (![defaults boolForKey:@"sendNotifications"])    
        return;
    
    NSLog(@"SCHEDULING NOTIFICATION");
        
    bool alreadyScheduled = FALSE;
    for (UILocalNotification *localNotification in [[UIApplication sharedApplication] scheduledLocalNotifications])           
        if ([[localNotification fireDate] compare:[self.scab healDate]] == NSOrderedSame)
            alreadyScheduled = TRUE;
    
    if (!alreadyScheduled && ([[self.scab healDate] compare:[NSDate date]] == NSOrderedDescending) && ![self.scab isComplete])
        [self scheduleNotification:[self.scab healDate]];
}

- (void)saveState {
    NSLog(@"SAVING STATE");    
    [self.defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[self scab]] forKey:@"scab"];
    [self.defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[self jars]] forKey:@"jars"];
    [self.defaults synchronize];    
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];    
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	[window release];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}
 
- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
    [jars release];
    [batchNode release];
    [scab release];
    [gameCenterBridge release];
    [defaults release];
	[super dealloc];
}
        
@end