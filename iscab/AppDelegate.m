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
#import "chipmunk.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation AppDelegate

@synthesize window, allScabs, allWounds;

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
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
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
	
	//[director setAnimationInterval:1.0/60];
	//[director setDisplayFPS:YES];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *mScabs = [defaults objectForKey:@"allScabs"];
    if (mScabs != nil) {
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mScabs];
        if (oldSavedArray != nil) {
            self.allScabs = [[NSMutableArray alloc] init];
            self.allScabs = oldSavedArray;
        }
    }
    
    NSData *mWounds = [defaults objectForKey:@"allWounds"];
    if (mWounds != nil) {
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mWounds];
        if (oldSavedArray != nil) {
            self.allWounds = [[NSMutableArray alloc] init];
            self.allWounds = oldSavedArray;
        }
    }
    
    [CDAudioManager sharedManager].mute = [defaults boolForKey:@"sound"];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"startup.wav"];

    cpInitChipmunk();
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];     
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allScabs] forKey:@"allScabs"];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.allWounds] forKey:@"allWounds"];
    
    [defaults synchronize]; 
}

- (NSMutableArray *)allScabs { 
    @synchronized(allScabs) {
        if (allScabs == nil)
            allScabs = [[NSMutableArray alloc] init];
        return allScabs;
    }
    return nil;
}

- (NSMutableArray *)allWounds { 
    @synchronized(allWounds) {
        if (allWounds == nil)
            allWounds = [[NSMutableArray alloc] init];
        return allWounds;
    }
    return nil;
}

- (void)removeScab:(ScabChunk *)scab initing:(bool)initing {
    [self.allScabs removeObject:scab];
    [scab removeFromParentAndCleanup:YES];
    
    if ([self.allScabs count] == 0 && !initing) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabcomplete.wav"];

        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Scab Complete!" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        title.position =  ccp(-100, 380);
        [title runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:ccp(160, 380)], [CCDelayTime actionWithDuration:2  ], [CCMoveTo actionWithDuration:0.3 position:ccp(500, 380)], [CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];
        
        [[[CCDirector sharedDirector] runningScene] addChild:title];    
    }
}

- (void)resetBoard {
    [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] updateBackground];
    [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] generateScabs];
    [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] displayBoard];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}
        
@end