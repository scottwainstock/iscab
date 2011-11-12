//
//  JarScene.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCShareLayer.h"

@interface JarScene : IScabCCShareLayer {
}

+ (id)scene;

- (NSString *)jarBackgroundImage;

@end