//
//  IScabCCShareLayer.h
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IScabCCLayer.h"

@interface IScabCCShareLayer : IScabCCLayer {
    NSString *sharedItemFileName;
}

@property (nonatomic, retain) NSString *sharedItemFileName;

@end