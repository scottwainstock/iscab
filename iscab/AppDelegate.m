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
#import "ScabChunk.h"
#import "GamePlay.h"
#import "Wound.h"
#import "Jar.h"
#import "chipmunk.h"

@implementation AppDelegate

@synthesize window, jars;

- (NSMutableArray *)jars { 
    @synchronized(jars) {
        if (jars == nil)
            jars = [[NSMutableArray alloc] init];
        return jars;
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
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scabs.plist"];
    
    [CDAudioManager sharedManager].mute = [defaults boolForKey:@"sound"];    
//    [[SimpleAudioEngine sharedEngine] playEffect:@"startup.wav"];

    cpInitChipmunk();
        
    NSData *mJars = [defaults objectForKey:@"jars"];
    if (mJars != nil) {
        NSLog(@"LOADING SAVED JARS");
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mJars];
        if (oldSavedArray != nil) {                
            for (Jar *savedJar in oldSavedArray) {
                Jar *jar = [[[Jar alloc] initWithNumScabChunks:savedJar.numScabChunks] autorelease];
                                
                [self.jars addObject:jar];
            }
        }
    } else {
        NSLog(@"CREATING NEW JARS");
        for (int i = 0; i < NUM_JARS_TO_FILL; i++) {
            [self.jars addObject:[[[Jar alloc] initWithNumScabChunks:0] autorelease]];
        }
    }
    
    for (int i = 0; i < [self.jars count]; i++) {
        NSLog(@"JAR %d: %d", i, [[self.jars objectAtIndex:i] numScabChunks]);
    }
    
	[[CCDirector sharedDirector] runWithScene: [MainMenu scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    [self saveState];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"TERMINATING");
    [self saveState];
    
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	[window release];
	[director end];	
}
   
- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)saveState {    
    NSLog(@"SAVING");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
            
    [defaults setValue:[(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] skinBackground] forKey:@"skinBackground"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] allScabChunks]] forKey:@"allScabChunks"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] allWounds]] forKey:@"allWounds"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[self jars]] forKey:@"jars"];
    
    [defaults synchronize]; 
}

- (Jar *)getCurrentJar {
    for (Jar *jar in self.jars) {
        if (jar.numScabChunks > 0 && jar.numScabChunks != NUM_SCABS_TO_FILL_JAR) {
            return jar;
        }
    }
    
    return [self.jars objectAtIndex:0];
}
 
- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}
        
@end