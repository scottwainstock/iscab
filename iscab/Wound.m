//
//  Wound.m
//  iscab
//
//  Created by Scott Wainstock on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wound.h"

@implementation Wound

@synthesize scabNo, bleeding;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.position.x forKey:@"xPos"]; 
    [coder encodeInt:self.position.y forKey:@"yPos"]; 
    [coder encodeInt:self.scabNo forKey:@"scabNo"];
    [coder encodeBool:self.bleeding forKey:@"bleeding"];
} 

- (id)initWithCoder:(NSCoder *)coder {    
    self = [[Wound alloc] init];
    
    if (self != nil) {
        self.savedLocation = ccp([coder decodeIntForKey:@"xPos"], [coder decodeIntForKey:@"yPos"]);
        self.scabNo = [coder decodeIntForKey:@"scabNo"];
        self.bleeding = [coder decodeBoolForKey:@"bleeding"];
    }
    
    return self; 
}

@end