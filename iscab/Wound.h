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
    int scabNo;
}

@property (nonatomic, assign) int scabNo;

@end