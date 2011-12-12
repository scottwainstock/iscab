//
//  CCMenuWideTouch.h
//  iscab
//
//  Created by Scott Wainstock on 12/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCMenuWideTouch : CCMenu {
    CGRect minTouchRect;
}

@property (nonatomic) CGRect minTouchRect;

@end
