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
    }
    
    return self;
}

@end