//
//  Wound.m
//  iscab
//
//  Created by Scott Wainstock on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wound.h"
#import "AppDelegate.h"

@implementation Wound

@synthesize isBleeding, isClean, scab;

- (void)dealloc {
    [scab release];
    [super dealloc];
}

- (void)destroy {
    [self.scab.wounds removeObject:self];
    [self.scab.scabChunkBorders removeObject:self];
    [super destroy];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.position.x forKey:@"xPos"]; 
    [coder encodeInt:self.position.y forKey:@"yPos"]; 
    [coder encodeBool:self.isBleeding forKey:@"isBleeding"];
    [coder encodeBool:self.isClean forKey:@"isClean"];
    [coder encodeInt:self.scabChunkNo forKey:@"scabChunkNo"];
} 

- (id)initWithCoder:(NSCoder *)coder {    
    self = [[Wound alloc] init];
    
    if (self != nil) {
        self.savedLocation = ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]);
        self.scabChunkNo = [coder decodeIntForKey:@"scabChunkNo"];
        self.isBleeding = [coder decodeBoolForKey:@"isBleeding"];
        self.isClean = [coder decodeBoolForKey:@"isClean"];
    }
    
    return self; 
}

+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding scabChunkNo:(int)scabChunkNo {
    if (isClean) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *skinColor = [app.defaults objectForKey:@"skinColor"];
        
        if ([skinColor isEqualToString:@"photo"])
            skinColor = @"light";
        
        return [NSString stringWithFormat:@"%@_clean_skin%d.png", skinColor, scabChunkNo];
    } else if (!isClean && isBleeding) {
        return [NSString stringWithFormat:@"bloody_skin%d.png", scabChunkNo];
    } else {
        return [NSString stringWithFormat:@"wound%d.png", scabChunkNo];
    }
}

@end