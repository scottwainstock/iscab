//
//  IScabCCShareLayer.m
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IScabCCShareLayer.h"
#import "SpecialScabs.h"
#import "AppDelegate.h"
#import "CCMenuWideTouch.h"
#import "SHK.h"

@implementation IScabCCShareLayer

@synthesize shareImage, specialButton, shareButton;

- (void)setupBackground {
    CCSprite *skinBG = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Jar_Background.jpg"]];
    [skinBG setAnchorPoint:ccp(0, 0)];
    [skinBG setPosition:ccp(0, 0)];
    [self addChild:skinBG z:-10 tag:SKIN_BACKGROUND_TAG];
}

- (void)setupNavigationIcons {    
    backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    [backButton setPosition:ccp(40, 40)];
    [backButton retain];
    
    specialButton = [CCMenuItemImage itemFromNormalImage:@"SpecialStar.png" selectedImage:@"SpecialStar_Tap.png" target:self selector:@selector(specialTapped:)];
    [specialButton setPosition:ccp(165, 41)];
    [specialButton retain];
    
    shareButton = [CCMenuItemImage itemFromNormalImage:@"Share.png" selectedImage:@"Share-Tap.png" target:self selector:@selector(shareTapped:)];
    [shareButton setPosition:ccp(280, 40)];
    [shareButton retain];
    
    iconMenu = [CCMenuWideTouch menuWithItems:backButton, specialButton, shareButton, nil];
    [iconMenu setPosition:CGPointZero];
    [iconMenu setMinTouchRect:CGRectMake(0, 0, ICON_TOUCH_AREA_SIZE, ICON_TOUCH_AREA_SIZE)];
    [self addChild:iconMenu z:2];
    [iconMenu retain];
}

- (void)specialTapped:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:TRANSITION_SPEED scene:[SpecialScabs scene]]];
}

- (void)captureScreenshot {
    UIImage *screenshot = [[CCDirector sharedDirector] screenshotUIImage];
    
    CGSize size = [screenshot size];
    CGRect cropRect = CGRectMake(0, 0, size.width, size.height - (CROP_SIZE * [[UIScreen mainScreen] scale]));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], cropRect);
    screenshot = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [self setShareImage:screenshot];
}

- (void)shareTapped:(CCMenuItem *)menuItem {
    if (self.shareImage == nil)
        [self captureScreenshot];
    
    SHKItem *item = [SHKItem image:shareImage title:@"iScab"];
    
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [actionSheet showInView:[[CCDirector sharedDirector] openGLView]];
}

- (void)dealloc {
    [specialButton release];
    [shareButton release];
    [shareImage release];
    [super dealloc];
}

@end