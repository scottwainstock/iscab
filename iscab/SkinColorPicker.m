//
//  SkinColorPicker.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkinColorPicker.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10

@implementation SkinColorPicker

+ (id)scene {
    CCScene *scene = [CCScene node];
    SkinColorPicker *layer = [SkinColorPicker node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"CHOOSE YOUR SKIN" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 3];
        title.position =  ccp(160, 380);
        [self addChild: title];
        
        CCLabelTTF *skinText = [CCLabelTTF labelWithString:@"This is where the skin picking will go." fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        skinText.position =  ccp(160, 300);
        [self addChild:skinText];
        
        [self addBackButton];
    }
    
    return self;
}

@end