//
//  Jar.h
//  iscab
//
//  Created by Scott Wainstock on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_NUM_SCAB_LEVELS 25

@interface Jar : NSObject <NSCoding> {
    int numScabLevels;
}

@property (nonatomic, assign) int numScabLevels;

- (id)initWithNumScabLevels:(int)mNumScabLevels;

@end