//
//  Help.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Help.h"
#import "AppDelegate.h"

@implementation Help

+ (id)scene {
    CCScene *scene = [CCScene node];
    Help *layer = [Help node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCSprite *helpText = [CCSprite spriteWithFile:@"help-text.png"];
        helpText.position = ccp(160, 240);
        [self addChild:helpText z:-1];
    
        CCMenuItem *stopButton = [CCMenuItemImage itemFromNormalImage:@"Stop-Pickin-Tap.png" selectedImage:@"Stop-Pickin.png" target:self selector:@selector(stopTapped:)];
        stopButton.position = ccp(165, 35);
        
        CCMenu *iconMenu = [CCMenu menuWithItems:stopButton, nil];
        iconMenu.position = CGPointZero;
        [self addChild:iconMenu z:2];
    }
    
    return self;
}

- (IBAction)stopTapped:(id)sender {
    NSLog(@"STOP");
}

@end