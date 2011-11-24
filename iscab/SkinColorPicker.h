//
//  SkinColorPicker.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IScabCCLayer.h"

#define CAMERA_TOUCHED_TAG 44
#define CAMERA_NOT_TOUCHED_TAG 55
#define CIRCLE_TAP 66

@interface SkinColorPicker : IScabCCLayer <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
}

+ (id)scene;

@end