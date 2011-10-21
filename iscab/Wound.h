//
//  Wound.h
//  iscab
//
//  Created by Scott Wainstock on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabSprite.h"

@interface Wound : IScabSprite <NSCoding> {
    bool isBleeding;
    bool isClean;
}

@property (nonatomic, assign) bool isClean;
@property (nonatomic, assign) bool isBleeding;

+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding scabChunkNo:(int)scabChunkNo;

@end