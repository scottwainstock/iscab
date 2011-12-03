//
//  Help.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Help.h"
#import "AppDelegate.h"

@implementation Help

+ (id)scene {
    CCScene *scene = [CCScene node];
    Help *layer = [Help node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCSprite *helpText = [CCSprite spriteWithFile:@"help-text.png"];
        helpText.position = ccp(160, 240);
        [self addChild:helpText z:-1];
    
        CCMenuItem *stopButton = [CCMenuItemImage itemFromNormalImage:@"Stop-Pickin.png" selectedImage:@"Stop-Pickin-Tap.png" target:self selector:@selector(stopTapped:)];
        stopButton.position = ccp(165, 35);
        
        iconMenu = [CCMenu menuWithItems:stopButton, nil];
        iconMenu.position = CGPointZero;
        [self addChild:iconMenu z:2];
    }
    
    return self;
}

- (IBAction)stopTapped:(id)sender {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stop Pickin'" 
                                                    message:@"Are you sure you want to stop Pickin' and empty all jars and start all over?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO" 
                                          otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"YES"]) {
        [app.defaults setObject:nil forKey:@"sendNotifications"];
        [app.defaults setObject:nil forKey:@"numScabsPicked"];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [app createNewJars];
        NSLog(@"STOP");
    }
}


@end