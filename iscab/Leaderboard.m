//
//  Leaderboards.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Leaderboard.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 10

@implementation Leaderboard

+ (id)scene {
    CCScene *scene = [CCScene node];
    Leaderboard *layer = [Leaderboard node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"LEADERBOARD" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 3];
        title.position =  ccp(160, 380);
        [self addChild: title];
        
        CCLabelTTF *leaderboardText = [CCLabelTTF labelWithString:@"This is where the leaderboard text will go." fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        leaderboardText.position =  ccp(160, 300);
        [self addChild:leaderboardText];
    }
    
    return self;
}

@end
