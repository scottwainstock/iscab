//
//  SkinColorPicker.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SkinColorPicker.h"
#import "AppDelegate.h"
#import "CCUIViewWrapper.h"

@implementation SkinColorPicker

@synthesize imagePicker, viewWrapper;

+ (id)scene {
    CCScene *scene = [CCScene node];
    SkinColorPicker *layer = [SkinColorPicker node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init {
    if ((self = [super init])) {   
        [self setIsTouchEnabled:YES];
        [[CCTextureCache sharedTextureCache] addImage:@"ChooseSkin_Tap.png"];

        CCSprite *pickerText = [CCSprite spriteWithFile:@"Choose_Skin.png"];
        [pickerText setPosition:ccp(160, 240)];
        [self addChild:pickerText];
        
        CCSprite *cameraNotTouched = [CCSprite spriteWithFile:@"camera.png"];
        [cameraNotTouched setPosition:ccp(230, 190)];
        [cameraNotTouched setTag:CAMERA_NOT_TOUCHED_TAG];
        [self addChild:cameraNotTouched];
    }
    
    return self;
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    CGPoint touchLocation = [self convertTouchToNodeSpace:[touches anyObject]];
    
    CGRect lightSkinBox   = CGRectMake(35, 265, 115, 105);
    CGRect mediumSkinBox  = CGRectMake(175, 265, 115, 105);
    CGRect darkSkinBox    = CGRectMake(35, 125, 115, 105);
    CGRect pictureSkinBox = CGRectMake(175, 125, 115, 105);

    CCSprite *circleTapped = [CCSprite spriteWithFile:@"ChooseSkin_Tap.png"];
    [circleTapped setTag:CIRCLE_TAP];
    
    if (CGRectContainsPoint(lightSkinBox, touchLocation)) {
        [circleTapped setPosition:ccp(90, 330)];
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"light" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(mediumSkinBox, touchLocation)) {
        [circleTapped setPosition:ccp(230, 330)];
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"medium" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(darkSkinBox, touchLocation)) {
        [circleTapped setPosition:ccp(90, 190)];
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"dark" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(pictureSkinBox, touchLocation)) {
        [circleTapped setPosition:ccp(230, 190)];
        [self addChild:circleTapped];
        
        CCSprite *cameraTouched = [CCSprite spriteWithFile:@"camera-Tap.png"];
        [cameraTouched setPosition:ccp(230, 190)];
        [cameraTouched setTag:CAMERA_TOUCHED_TAG];
        
        [self addChild:cameraTouched];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"PIX");
            imagePicker = [[UIImagePickerController alloc] init];        
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker setDelegate:self];
            [imagePicker setAllowsEditing:NO];
            [imagePicker presentModalViewController:imagePicker animated:YES];
            
            viewWrapper = [CCUIViewWrapper wrapperForUIView:imagePicker.view];
            [viewWrapper setContentSize:CGSizeMake(app.screenWidth, app.screenHeight)];
            
            if ([[UIScreen mainScreen] scale] == 2.00)
                [viewWrapper setPosition:ccp(320, 0)];
            else
                [viewWrapper setPosition:ccp(app.screenWidth / 2, app.screenHeight / 2)];
            
            [self addChild:viewWrapper];
            NSLog(@"WRAPPER ADDED");
        } else {
            NSLog(@"NO CAMERA");
        }
        
        [self removeChild:[self getChildByTag:CAMERA_NOT_TOUCHED_TAG] cleanup:YES];
    }
        
    [self setupBackground];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeChild:[self getChildByTag:CAMERA_TOUCHED_TAG] cleanup:YES];
    [self removeChild:[self getChildByTag:CIRCLE_TAP] cleanup:NO];

    if (![self getChildByTag:CAMERA_NOT_TOUCHED_TAG]) {
        CCSprite *cameraNotTouched = [CCSprite spriteWithFile:@"camera.png"];
        [cameraNotTouched setPosition:ccp(230, 190)];
        [cameraNotTouched setTag:CAMERA_NOT_TOUCHED_TAG];
        [self addChild:cameraNotTouched];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)removePicker:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
	[picker.view removeFromSuperview];
    [self removeChild:viewWrapper cleanup:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self removePicker:picker];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIImage *newImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
	newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(app.screenWidth, app.screenHeight)];
    
    [self removePicker:picker];
    
    [app.defaults setObject:UIImagePNGRepresentation(newImage) forKey:@"photoBackground"];
    [app.defaults setObject:@"photo" forKey:@"skinColor"];    
    
    NSLog(@"SAVED");
    
    [self setupBackground];
}

- (void)dealloc {
    [imagePicker release];
    [super dealloc];
}

@end