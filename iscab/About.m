//
//  About.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "About.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10

@implementation About

+ (id)scene {
    CCScene *scene = [CCScene node];
    About *layer = [About node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"ABOUT" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 6];
        title.position =  ccp(160, 380);
        [self addChild: title];
        
        CCLabelTTF *aboutText = [CCLabelTTF labelWithString:@"This is where the about text will go." fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        aboutText.position =  ccp(160, 300);
        [self addChild:aboutText];
        
        /*CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
        logo.position = ccp(160, 120);
        [self addChild:logo z:1];*/        
    }
    
    return self;
}

@end