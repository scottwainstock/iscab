//
//  IScabCCShareLayer.h
//  iscab
//
//  Created by Scott Wainstock on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IScabCCLayer.h"

#define CROP_SIZE 60

@interface IScabCCShareLayer : IScabCCLayer {
    UIImage *shareImage;
}

@property (nonatomic, retain) UIImage *shareImage;

- (void)shareTapped:(CCMenuItem *)menuItem;

@end