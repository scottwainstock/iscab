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
    CCMenuItem *specialButton;
    CCMenuItem *shareButton;
}

@property (nonatomic, retain) UIImage *shareImage;
@property (nonatomic, retain) CCMenuItem *specialButton;
@property (nonatomic, retain) CCMenuItem *shareButton;

- (void)shareTapped:(CCMenuItem *)menuItem;

@end