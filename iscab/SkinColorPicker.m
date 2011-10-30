//
//  SkinColorPicker.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkinColorPicker.h"
#import "AppDelegate.h"

@implementation SkinColorPicker

+ (id)scene {
    CCScene *scene = [CCScene node];
    SkinColorPicker *layer = [SkinColorPicker node];
    [scene addChild: layer];
    
    return scene;
}

- (IBAction)changeSkinColor:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"skinColor"] isEqualToString:@"light"]) {
        [defaults setObject:@"dark" forKey:@"skinColor"];
    } else {
        [defaults setObject:@"light" forKey:@"skinColor"];        
    }
}

- (id)init {
    if( (self=[super init] )) {        
        CCMenuItemImage *pickerText = [CCMenuItemImage itemFromNormalImage:@"choose-skin-text.png" selectedImage: @"choose-skin-text.png" target:self selector:@selector(changeSkinColor:)];
        
        CCMenu *menu = [CCMenu menuWithItems:pickerText, nil];       
        menu.position = ccp(160, 240);
        [self addChild:menu];        
    }
    
    return self;
}

@end