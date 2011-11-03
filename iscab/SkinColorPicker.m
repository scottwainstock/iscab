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
    
    [self setupBackground];
}

- (id)init {
    if( (self=[super init] )) {   
        self.isTouchEnabled = YES;

        CCSprite *pickerText = [CCSprite spriteWithFile:@"choose-skin-text.png"];
        pickerText.position = ccp(160, 240);
        [self addChild:pickerText];        
    }
    
    return self;
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    CGPoint touchLocation = [self convertTouchToNodeSpace:[touches anyObject]];
    
    CGRect lightSkinBox   = CGRectMake(35, 265, 115, 105);
    CGRect mediumSkinBox  = CGRectMake(175, 265, 115, 105);
    CGRect darkSkinBox    = CGRectMake(35, 125, 115, 105);
    CGRect pictureSkinBox = CGRectMake(175, 125, 115, 105);

    if (CGRectContainsPoint(lightSkinBox, touchLocation)) {
        [defaults setObject:@"light" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(mediumSkinBox, touchLocation)) {
        [defaults setObject:@"medium" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(darkSkinBox, touchLocation)) {
        [defaults setObject:@"dark" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(pictureSkinBox, touchLocation)) {
        NSLog(@"PICZ");
    }
        
    [self setupBackground];
}

@end