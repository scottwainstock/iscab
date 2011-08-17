//
//  Wound.m
//  iscab
//
//  Created by Scott Wainstock on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wound.h"

@implementation Wound

@synthesize scabNo;

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInt:self.scabNo forKey:@"scabNo"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Wound alloc] initWithTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"scab%d.png", [coder decodeIntForKey:@"scabNo"]]]]];        
    [self setTexture:[[CCTexture2D alloc] initWithImage:[UIImage imageNamed:@"wound0.png"]]];
    
    self.scabNo = [coder decodeIntForKey:@"scabNo"];
    
    [super initWithCoder:coder];
    
    return self; 
} 


@end