//
//  About.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "About.h"
#import "AppDelegate.h"

@implementation About

@synthesize aboutText;

+ (id)scene {
    CCScene *scene = [CCScene node];
    About *layer = [About node];
    [scene addChild: layer];
    
    return scene;
}

- (id)init {
    if( (self=[super init] )) {
        CCSprite *title = [CCSprite spriteWithFile:@"about-header.png"];
        [title setPosition:ccp(160, 430)];
        [self addChild:title z:10];
        
        CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
        [logo setPosition:ccp(160, 300)];
        [self addChild:logo z:10];

        aboutText = [[UITextView alloc] init];
        [aboutText setText:@"Scott Wainstock and Drew Marshall are BEEFBRAIN. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum massa sem, lobortis sed mattis ac, imperdiet et augue. Donec molestie leo id sapien iaculis congue. Maecenas congue facilisis leo, ac viverra eros fringilla ac. Ut arcu tellus, lacinia quis sollicitudin et, auctor a tortor. Nam tortor dui, placerat vitae faucibus id, auctor at arcu. Suspendisse lobortis lectus et mi bibendum ac cursus nibh pretium. Nullam nunc felis, fermentum ut ullamcorper id, porttitor quis velit. Quisque ut sapien ut mi eleifend adipiscing. Vestibulum eu diam at est dapibus faucibus ut interdum diam. Donec accumsan dolor quis sapien convallis ornare. Sed tempus ornare diam non volutpat. Sed nec semper lacus. Duis varius vehicula lectus, eu porttitor arcu ultrices quis. Fusce venenatis, erat at suscipit tempor, neque orci scelerisque mi, quis sagittis lacus arcu non magna. In in dolor orci. Curabitur porta neque sed eros posuere et sollicitudin nisi bibendum."];
        [aboutText setFont:[UIFont fontWithName:DEFAULT_FONT_NAME size:DEFAULT_FONT_SIZE * 1.39]];
        [aboutText setBackgroundColor:[UIColor clearColor]];
        [aboutText setFrame:CGRectMake(30, 300, 260, 115)];
        [[[CCDirector sharedDirector] openGLView] addSubview:aboutText];
        
        /*
        [title release];
        [logo release];
        [aboutText release];*/
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    [aboutText removeFromSuperview];
    //[aboutText release];
}

@end