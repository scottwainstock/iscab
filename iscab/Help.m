//
//  Help.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Help.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10

@implementation Help

+ (id)scene {
    CCScene *scene = [CCScene node];
    Help *layer = [Help node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"HELP" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 6];
        title.position =  ccp(160, 380);
        [self addChild: title];
        
        CCLabelTTF *helpText = [CCLabelTTF labelWithString:@"This is where the help text will go." fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        helpText.position =  ccp(160, 300);
        [self addChild: helpText];
    }
    
    return self;
}

@end