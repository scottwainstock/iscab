//
//  Jar.h
//  iscab
//
//  Created by Scott Wainstock on 10/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_SCABS_TO_FILL_JAR 1000

@interface Jar : NSObject <NSCoding> {
    int numScabChunks;
}

@property (nonatomic, assign) int numScabChunks;

- (id)initWithNumScabChunks:(int)numScabChunks;

@end