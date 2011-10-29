//
//  ScabChunk.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Scab.h"
#import "IScabSprite.h"

#define DISTANCE_FROM_CENTER_TO_REMAIN_CLEAN 25.0

@interface ScabChunk : IScabSprite <NSCoding> {
    int priority;
    int health;

    Scab *scab;
    NSString *type;
}

- (void)ripOffScab;
- (NSString *)filename;

@property (assign) int priority;
@property (assign) int health;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) Scab *scab;

@end