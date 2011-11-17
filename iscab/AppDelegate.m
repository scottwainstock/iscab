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
#import "Jar.h"
#import "chipmunk.h"
#import "GameCenterBridge.h"

@implementation AppDelegate

@synthesize window, jars, screenWidth, screenHeight, batchNode, scabs, backButton, jarButton;

- (NSMutableArray *)scabs { 
    @synchronized(scabs) {
        if (scabs == nil)
            scabs = [[NSMutableArray alloc] init];
        return scabs;
    }
    return nil;
}

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

- (void) removeStartupFlicker
{
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

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    NSLog(@"STARTING APPLICATION DID FINISH LAUNCHING");
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
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
	if( ! [director enableRetinaDisplay:YES] )
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([GameCenterBridge isGameCenterAPIAvailable]) {
        [defaults setBool:YES forKey:@"gameCenterEnabled"];
        [GameCenterBridge authenticateLocalPlayer];
    } else {
        [defaults setBool:NO forKey:@"gameCenterEnabled"];
    }
    
    if ([defaults objectForKey:@"highScore"]) {
        [GameCenterBridge reportScore:[[defaults objectForKey:@"highScore"] longLongValue] forCategory:@"iscab_leaderboard"];
        [defaults removeObjectForKey:@"highScore"];
    }

    //THIS IS JUST FOR TESTING PURPOSES
    [defaults setBool:YES forKey:@"xxx"];
    [defaults setBool:YES forKey:@"jesus"];
    [defaults setBool:YES forKey:@"heart"];
    [defaults setBool:YES forKey:@"illuminati"];
    [defaults setBool:YES forKey:@"sass"];
    //
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scabs.plist"];
        
    if ([defaults stringForKey:@"skinColor"] == NULL)
        [defaults setObject:@"light" forKey:@"skinColor"];

    [defaults setBool:[defaults boolForKey:@"sound"] ? FALSE : TRUE forKey:@"sound"];
    [defaults synchronize];

    
    [CDAudioManager sharedManager].mute = [defaults boolForKey:@"sound"];    
//    [[SimpleAudioEngine sharedEngine] playEffect:@"startup.wav"];

    cpInitChipmunk();
            
    NSData *mJars = [defaults objectForKey:@"jars"];
    if (mJars != nil) {
        NSLog(@"LOADING SAVED JARS");
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mJars];
        if (oldSavedArray != nil) {                
            for (Jar *savedJar in oldSavedArray) {
                Jar *jar = [[Jar alloc] initWithNumScabLevels:savedJar.numScabLevels];
                                
                [self.jars addObject:jar];
            }
        }
    } else {
        NSLog(@"CREATING NEW JARS");
        for (int i = 0; i < NUM_JARS_TO_FILL; i++) {
            [self.jars addObject:[[Jar alloc] initWithNumScabLevels:0]];
        }
        
        [defaults setObject:[NSDate date] forKey:@"startTime"];
    }
    
    for (int i = 0; i < [self.jars count]; i++) {
        NSLog(@"JAR %d: %d", i, [[self.jars objectAtIndex:i] numScabLevels]);
    }
    
    
    //THIS IS JUST FOR TESTING PURPOSES
    for (int i = 0; i < [self.jars count] - 1; i++) {
        [[self.jars objectAtIndex:i] setNumScabLevels:MAX_NUM_SCAB_LEVELS];
    }
    [[self.jars objectAtIndex:2] setNumScabLevels:MAX_NUM_SCAB_LEVELS - 1];
    //
    
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
    
    [[CCDirector sharedDirector] runWithScene:[MainMenu scene]];
}

- (Jar *)currentJar {
    for (Jar *jar in self.jars) {
        if (jar.numScabLevels > 0 && jar.numScabLevels < MAX_NUM_SCAB_LEVELS)
            return jar;
    }
    
    for (Jar *jar in self.jars) {
        if (jar.numScabLevels < MAX_NUM_SCAB_LEVELS)
            return jar;
    }    
    
    return [self.jars objectAtIndex:0];
}

- (CGPoint)centerOfAllScabs {
    int x = 0;
    int y = 0;
    for (Scab *scab in self.scabs) {
        x += scab.center.x;
        y += scab.center.y;
    }
    
    return CGPointMake(x / [self.scabs count], y / [self.scabs count]);
}

- (void)scheduleNotification:(NSDate *)date {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    notification.alertBody = @"You've got an itchy scab.";
    notification.alertAction = @"Take me to it.";
    notification.soundName = [NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [notification release];
    
    NSLog(@"NOTIFICATION SCHEDULED FOR: %@", date);
    NSLog(@"NUMBER OF NOTIFICATIONS: %d", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"WILL RESIGN ACTIVE");
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"APPLICATION WENT ACTIVE");
	[[CCDirector sharedDirector] resume];
    
    if ([[CCDirector sharedDirector] runningScene].tag == GAMEPLAY_SCENE_TAG) {
        [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:GAMEPLAY_SCENE_TAG] displayExistingBoard];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    NSLog(@"DID ENTER BACKGROUND");
	[[CCDirector sharedDirector] stopAnimation];
    
    if ([[CCDirector sharedDirector] runningScene].tag == GAMEPLAY_SCENE_TAG) {
        [self saveState];
    }
}

- (void)scheduleNotifications {
    for (Scab *scab in self.scabs) {
        NSLog(@"SCHEDULING NOTIFICATION");
        [scab setIsAged:YES];
        
        bool alreadyScheduled = FALSE;
        for (UILocalNotification *localNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {            
            if ([[localNotification fireDate] compare:[scab healDate]] == NSOrderedSame)
                alreadyScheduled = TRUE;
        }
        
        if (!alreadyScheduled && ([[scab healDate] compare:[NSDate date]] == NSOrderedDescending) && ![scab isComplete])
            [self scheduleNotification:[scab healDate]];
    }
}

- (void)saveState {
    [self scheduleNotifications];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[self scabs]] forKey:@"scabs"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[self jars]] forKey:@"jars"];
    [defaults synchronize];
    
    for (Scab *scab in self.scabs) {
        [scab reset];
    }
    self.scabs = nil;
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"TERMINATING");
    
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
	[super dealloc];
}
        
@end