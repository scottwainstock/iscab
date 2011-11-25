//
//  JarScene.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JarScene.h"
#import "AppDelegate.h"

@implementation JarScene

AppDelegate *app;

+ (id)scene {
    CCScene *scene = [CCScene node];
    JarScene *layer = [JarScene node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if ((self=[super init])) {
        CCSprite *bg = [CCSprite spriteWithFile:[self jarBackgroundImage]];
        bg.position = ccp(160, 240);
        [self addChild:bg z:0];
        
        int numScabLevels = [app.currentJar numScabLevels];
        
        if (numScabLevels > 0) {
            CCSprite *scabLevel = [CCSprite spriteWithFile:[NSString stringWithFormat:@"jarlayer%d.png", numScabLevels]];
            scabLevel.position = ccp(160, 240);
            [self addChild:scabLevel z:4];
        }
            
        CCSprite *jarCover = [CCSprite spriteWithFile:@"Jar-Front.png"];
        jarCover.position = ccp(160, 240);
        [self addChild:jarCover z:4];
    }
                               
    return self;
}

- (NSString *)jarBackgroundImage {    
    int numFilledJars = 0;
    for (Jar *jar in [app jars]) {
        if (jar.numScabLevels == MAX_NUM_SCAB_LEVELS)
            numFilledJars++;
    }
    
    switch (numFilledJars) {
        case 0:
            return @"Jar-Back.png";
        case 1:
            return @"one-full.png";
        case 2:
            return @"two-full.png";
        default:
            return @"two-full.png";
    }
}

@end
