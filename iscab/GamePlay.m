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
#import "MainMenu.h"

@implementation GamePlay

@synthesize batchNode;

static AppDelegate *app;

- (CCSpriteBatchNode *)batchNode { 
    @synchronized(batchNode) {
        if (batchNode == nil)
            batchNode = [[CCSpriteBatchNode alloc] init];
        return batchNode;
    }
    return nil;
}

- (void)createSpace {    
    space = cpSpaceNew();
    space->gravity = ccp(0, -750);
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
}

- (void)update:(ccTime)dt {
    cpSpaceStep(space, dt);
        
    for (IScabSprite *sprite in batchNode.children) {
        [sprite update];
        
        if ([sprite respondsToSelector:@selector(health)] && sprite.position.y < 0) {
            [self removeScab:(ScabChunk *)sprite];
        }
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
        0, 0, 1, 4.0, 4.0, 2.0
    };
    
    drawSpace(space, &options);
}

- (id)init {
    if((self=[super init])) {
        self.isTouchEnabled = YES;
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [self createSpace]; 
        
        mouse = cpMouseNew(space);

        [self updateBackground];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"scabs.plist"];
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
        [self addChild:batchNode];

        NSLog(@"SCAB COUNT %d", [app.allScabs count]);
        if (![app.allScabs count]) {
            [self generateScabs];
        }
                
        /*
        [self displayBoard];
         */
                        
        [self scheduleUpdate];
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
    
    /*
    CCMenuItem *homeButton = [CCMenuItemImage itemFromNormalImage:@"home-icon.png" selectedImage:@"home-icon.png" target:self selector:@selector(homeTapped:)];
    homeButton.position = ccp(40, 40);
    [self addChild:homeButton z:2];*/
}

- (void)homeTapped:(CCMenuItem  *)menuItem {  
    NSLog(@"HOME TAPPED");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeUp transitionWithDuration:0.5f scene:[MainMenu scene]]];
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
    for (int x = 0; x < 2; x++) { 
        int scabIndex = arc4random() % 4;
        
        float startX = arc4random() % 300;
        float startY = (arc4random() % 300) + 100;

        [batchNode addChild:[self createScab:CGPointMake(startX, startY) usingScabIndex:scabIndex havingPriority:1]];        
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
}

- (ScabChunk *)createScab:(CGPoint)coordinates usingScabIndex:(int)scabIndex havingPriority:(int)priority {    
    ScabChunk *scab = [[[ScabChunk alloc] initWithSpace:space location:ccp(coordinates.x, coordinates.y) filename:[NSString stringWithFormat:@"scab%d.png", scabIndex]] autorelease]; 

    cpBodySetAngle(scab.body, CC_DEGREES_TO_RADIANS(arc4random() % 360));
    
    [scab setScabNo:scabIndex];
    [scab setPriority:priority];
    [scab setHealth:priority * 2];
    
   // [self clearLowerScabs:scab];    
    [app.allScabs addObject:scab];

    NSLog(@"ALL SCABS %d", [app.allScabs count]);
    
    return scab;
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
        if (![(IScabSprite *)shape->data respondsToSelector:@selector(health)])
            return YES;
        
        ScabChunk *sprite = (ScabChunk *)shape->data;

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
        if (![(IScabSprite *)shape->data respondsToSelector:@selector(health)])
            return;
        
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
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    cpShape *shape = cpSpacePointQueryFirst(space, touchLocation, GRABABLE_MASK_BIT, 0);
    if (shape) {
        if (![(IScabSprite *)shape->data respondsToSelector:@selector(health)])
            return;
        
        ScabChunk *sprite = (ScabChunk *) shape->data;

        //280 and 40 correspond to the location of the jar
        float xDif = sprite.position.x - 280;
        float yDif = sprite.position.y - 40;
        float distance = sqrt(xDif * xDif + yDif * yDif);
    
        if (distance < 20) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"scabinjar.wav"];
            [self removeScab:sprite];
        }
        
        cpMouseRelease(mouse);
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
}

- (void)removeScab:(ScabChunk *)chunk {
    NSLog(@"REMOVE");
    [app removeScab:chunk initing:NO];
}

- (void)createWound:(ScabChunk *)scab {
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    Wound *wound = [[[Wound alloc] initWithSpace:space location:ccp(scab.position.x, scab.position.y) filename:@"wound0.png"] autorelease];     
    cpBodySetAngle(wound.body, self.rotation);
    wound.scabNo = scab.scabNo;
    
    [app.allWounds addObject:wound];
    [batchNode addChild:wound];        
}

- (void)dealloc {
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [super dealloc];
}

@end