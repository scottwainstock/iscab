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
        self.isTouchEnabled = YES;
        [[CCTextureCache sharedTextureCache] addImage:@"ChooseSkin_Tap.png"];

        CCSprite *pickerText = [CCSprite spriteWithFile:@"Choose_Skin.png"];
        pickerText.position = ccp(160, 240);
        [self addChild:pickerText];
        
        CCSprite *cameraNotTouched = [CCSprite spriteWithFile:@"camera.png"];
        cameraNotTouched.position = ccp(228, 181);
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
        circleTapped.position = ccp(90, 320);
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"light" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(mediumSkinBox, touchLocation)) {
        circleTapped.position = ccp(230, 320);
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"medium" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(darkSkinBox, touchLocation)) {
        circleTapped.position = ccp(90, 180);
        [self addChild:circleTapped];
        
        [app.defaults setObject:@"dark" forKey:@"skinColor"];
    } else if (CGRectContainsPoint(pictureSkinBox, touchLocation)) {
        circleTapped.position = ccp(230, 180);
        [self addChild:circleTapped];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"PIX");
            imagePicker = [[UIImagePickerController alloc] init];        
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [imagePicker presentModalViewController:imagePicker animated:YES];
            
            viewWrapper = [CCUIViewWrapper wrapperForUIView:imagePicker.view];
            viewWrapper.contentSize = CGSizeMake(app.screenWidth, app.screenHeight);
            viewWrapper.position = ccp(app.screenWidth / 2, app.screenHeight / 2);
            [self addChild:viewWrapper];
            NSLog(@"WRAPPER ADDED");
        } else {
            NSLog(@"NO CAMERA");
        }
        
        [self removeChild:[self getChildByTag:CAMERA_NOT_TOUCHED_TAG] cleanup:YES];
        
        CCSprite *cameraTouched = [CCSprite spriteWithFile:@"camera-Tap.png"];
        cameraTouched.position = ccp(228, 181);
        [cameraTouched setTag:CAMERA_TOUCHED_TAG];
        
        [self addChild:cameraTouched];
    }
        
    [self setupBackground];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeChild:[self getChildByTag:CAMERA_TOUCHED_TAG] cleanup:YES];
    [self removeChild:[self getChildByTag:CIRCLE_TAP] cleanup:YES];
    
    CCSprite *cameraNotTouched = [CCSprite spriteWithFile:@"camera.png"];
    cameraNotTouched.position = ccp(228, 181);
    [cameraNotTouched setTag:CAMERA_NOT_TOUCHED_TAG];
    [self addChild:cameraNotTouched];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
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