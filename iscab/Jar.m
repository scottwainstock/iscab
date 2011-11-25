//
//  Jar.m
//  iscab
//
//  Created by Scott Wainstock on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Jar.h"

@implementation Jar

@synthesize numScabLevels;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.numScabLevels forKey:@"numScabLevels"]; 
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Jar alloc] init];
    
    if (self != nil)
        self.numScabLevels = [coder decodeIntForKey:@"numScabLevels"];
    
    return self; 
}

- (id)initWithNumScabLevels:(int)mNumScabLevels {
    if ((self = [super init]))
        self.numScabLevels = mNumScabLevels;
    
    return self;
}

@end