//
//  SpecialScabs.h
//  iscab
//
//  Created by Scott Wainstock on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IScabCCShareLayer.h"

@interface SpecialScabs : IScabCCShareLayer {
}

+ (id)scene;
+ (NSArray *)specialScabNames;

- (void)addFoundScabs;

@end