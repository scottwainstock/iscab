//
//  SpecialScabDetail.h
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IScabCCLayer.h"

@interface SpecialScabDetail : IScabCCLayer {
}

+ (id)scene;
+(id)nodeWithScabName:(NSString *)scabName;

- (id)initWithScabName:(NSString *)scabName;

@end
