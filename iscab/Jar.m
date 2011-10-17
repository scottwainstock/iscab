//
//  Jar.m
//  iscab
//
//  Created by Scott Wainstock on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Jar.h"

@implementation Jar

@synthesize numScabChunks;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.numScabChunks forKey:@"numScabChunks"]; 
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Jar alloc] init];
    
    if (self != nil) {
        self.numScabChunks = [coder decodeIntForKey:@"numScabChunks"];
    }
    
    return self; 
}

- (id)initWithNumScabChunks:(int)mNumScabChunks {
    if ((self = [super init])) {
        self.numScabChunks = mNumScabChunks;
    }
    
    return self;
}

@end