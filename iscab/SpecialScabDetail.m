//
//  SpecialScabDetail.m
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpecialScabDetail.h"

@implementation SpecialScabDetail

+ (id)scene {
    CCScene *scene = [CCScene node];
    SpecialScabDetail *layer = [SpecialScabDetail node];
    [scene addChild:layer];
    
    return scene;
}

+(id)nodeWithScabName:(NSString *)scabName {
    return [[[self alloc] initWithScabName:scabName] autorelease];
}

- (id)initWithScabName:(NSString *)scabName {
    if ((self=[super init])) {
        CCSprite *scabImage = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-detail.png", scabName]];
        scabImage.position = ccp(160, 300);
        [self addChild:scabImage z:0];        
    }
    
    return self;
}

- (void)setupBackground {
    CCSprite *skinBG = [CCSprite spriteWithFile:[NSString stringWithFormat:@"Jar_Background.jpg"]];
    skinBG.anchorPoint = ccp(0, 0);
    skinBG.position = ccp(0, 0);
    [self addChild:skinBG z:-10 tag:SKIN_BACKGROUND_TAG];
}

- (void)setupNavigationIcons {    
    CCMenuItem *backButton = [CCMenuItemImage itemFromNormalImage:@"Back.png" selectedImage:@"Back-Hover.png" target:self selector:@selector(backTapped:)];
    backButton.position = ccp(40, 40);
    
    CCMenu *iconMenu = [CCMenu menuWithItems:backButton, nil];
    iconMenu.position = CGPointZero;
    [self addChild:iconMenu z:2];
}

@end