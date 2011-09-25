//
//  JarScene.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JarScene.h"


@implementation JarScene

+ (id)scene {
    CCScene *scene = [CCScene node];
    JarScene *layer = [JarScene node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCSprite *bg = [CCSprite spriteWithFile:@"jar-background.png"];
        bg.position = ccp(175, 250);
        [self addChild:bg z:0];
    }
    return self;
}

@end
