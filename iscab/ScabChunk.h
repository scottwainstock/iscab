//
//  ScabChunk.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabSprite.h"

@interface ScabChunk : IScabSprite <NSCoding> {
    int priority;
    int health;
    int scabNo;

    id action;
    
    NSString *type;
}

- (void)ripOffScab;

@property (assign) int priority;
@property (assign) int health;
@property (nonatomic, assign) int scabNo;
@property (nonatomic, assign) id action;
@property (nonatomic, retain) NSString *type;

@end