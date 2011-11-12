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

@end