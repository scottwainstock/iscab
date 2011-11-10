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

@interface SkinColorPicker : IScabCCLayer <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
}

+ (id)scene;

@end