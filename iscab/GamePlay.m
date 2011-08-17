//
//  GamePlay.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlay.h"
#import "ScabChunk.h"
#import "AppDelegate.h"
#import "Wound.h"
#import "drawSpace.h"
#import "SimpleAudioEngine.h"

@implementation GamePlay

AppDelegate *app;

- (void)createSpace {
    space = cpSpaceNew();
    space->gravity = ccp(0, -750);
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
}

- (void)update:(ccTime)dt {
    cpSpaceStep(space, dt);
    
    for (ScabChunk *chunk in app.allScabs) {
        [chunk update];
    }
}

+ (id)scene {
    CCScene *scene = [CCScene node];
    GamePlay *layer = [GamePlay node];
    [scene addChild:layer z:0 tag:1];
    
    return scene;
}

- (void)draw {
    drawSpaceOptions options = {
        0, // drawHash
        0, // drawBBs,
        1, // drawShapes
        4.0, // collisionPointSize
        4.0, // bodyPointSize,
        2.0 // lineThickness
    };
    
    drawSpace(space, &options);
}

- (id)init {
    if((self=[super init])) {
        self.isTouchEnabled = YES;
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [self createSpace]; 
        [self scheduleUpdate];
        
        mouse = cpMouseNew(space);

        [self updateBackground];

        //if (![app.allScabs count]) {
            [self generateScabs];
        //}
                
        /*
        [self displayBoard];
         */
    }
            
    return self;
}

- (void)updateBackground {
    [(CCSprite *)[self getChildByTag:777] removeFromParentAndCleanup:YES];
    [(CCSprite *)[self getChildByTag:778] removeFromParentAndCleanup:YES];
    
    int bgIndex = arc4random() % 8;
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"skin_background%d.png", bgIndex]];
    bg.tag = 777;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    
    CCSprite *jarIcon = [CCSprite spriteWithFile:@"jar-icon.png"];
    jarIcon.tag = 778;
    jarIcon.position = ccp(280, 40);
    [self addChild:jarIcon z:1];
}

- (void)displayBoard {
    for (Wound *wound in [app allWounds]) {
        [self addChild:wound z:0];            
    }
    
    for (ScabChunk *scab in [app allScabs]) {
        [self addChild:scab z:1];            
    }    
}

- (void)generateScabs {
    for (Wound *wound in [app allWounds]) {
        [app.allWounds removeObject:wound];
        [wound removeFromParentAndCleanup:YES];
    }
    
    for (int x = 0; x < 1; x++) { 
        int scabIndex = arc4random() % 4;
        
        float startX = arc4random() % 300;
        float startY = (arc4random() % 300) + 100;
        
        [self createScab:CGPointMake(startX, startY) usingScabIndex:scabIndex havingPriority:1];
    }
    /*
     for (int x = 0; x < 10; x++) {
     float startX = arc4random() % 300;
     float startY = (arc4random() % 300) + 100;
     
     if (startX < 100) {
     startX += 50;
     } else if (startX > 200) {
     startX -= 50;
     }
     
     if (startY < 100) {
     startY += 50;
     } else if (startY > 200) {
     startY -= 50;
     }
     
     [self createScab:CGPointMake(startX, startY) usingScabImage:@"scab0.png" havingPriority:2];
     }
     */
    
    //[[[(GamePlay *)[CCDirector sharedDirector] runningScene] getChildByTag:1] displayBoard];    
}

- (void)createScab:(CGPoint)coordinates usingScabIndex:(int)scabIndex havingPriority:(int)priority {    
    ScabChunk *scab = [[[ScabChunk alloc] initWithSpace:space location:ccp(coordinates.x, coordinates.y) filename:[NSString stringWithFormat:@"scab%d.png", scabIndex]] autorelease];    
    cpBodySetAngle(scab.body, CC_DEGREES_TO_RADIANS(arc4random() % 360));
    
    [scab setScabNo:scabIndex];
    [scab setPriority:priority];
    [scab setHealth:priority * 2];
    
    [self clearLowerScabs:scab];    
    [app.allScabs addObject:scab];
}

- (void)clearLowerScabs:(ScabChunk *)newScab {
    NSMutableArray *scabsToDelete = [[NSMutableArray alloc] init];
    for (ScabChunk *checkScab in [app allScabs]) {        
        if (CGRectIntersectsRect([newScab boundingBox], [checkScab boundingBox])) {
            if (ccpDistance(newScab.position, checkScab.position) < 50.0) {
                [scabsToDelete addObject:checkScab];
            }
        }
    }
    
    for (ScabChunk *deleteScab in scabsToDelete) {
        [app removeScab:deleteScab initing:YES];
    }
    
    [scabsToDelete release];
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    cpShape *shape = cpSpacePointQueryFirst(space, touchLocation, GRABABLE_MASK_BIT, 0);
    if (shape) {
        ScabChunk *sprite = (ScabChunk *) shape->data;
        
        if ([sprite health] > 0) {
            sprite.health -= 1;
        }
        
        [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % 3]];
    }
    
    cpMouseGrab(mouse, touchLocation, false);
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    cpShape *shape = cpSpacePointQueryFirst(space, touchLocation, GRABABLE_MASK_BIT, 0);
    if (shape) {
        ScabChunk *sprite = (ScabChunk *) shape->data;
        if ([sprite health] > 0) {
            return;
        }
        
        if (([sprite health] <= 0) && ![sprite free]) {
            [sprite ripOffScab];
            
            cpBodySetMass(shape->body, 1.0);
            cpSpaceAddBody(space, shape->body);
        }
        
        cpMouseMove(mouse, touchLocation);
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    cpMouseRelease(mouse);
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    cpMouseRelease(mouse);    
}

- (void)dealloc {
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [super dealloc];
}

@end