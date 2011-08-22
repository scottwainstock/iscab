//
//  GamePlay.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlay.h"
#import "ScabChunk.h"
#import "Wound.h"
#import "drawSpace.h"
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "CCParticleMyBlood.h"
#import "cpSpace.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation GamePlay

@synthesize batchNode, allScabs, allWounds;

- (NSMutableArray *)allScabs { 
    @synchronized(allScabs) {
        if (allScabs == nil)
            allScabs = [[NSMutableArray alloc] init];
        return allScabs;
    }
    return nil;
}

- (NSMutableArray *)allWounds { 
    @synchronized(allWounds) {
        if (allWounds == nil)
            allWounds = [[NSMutableArray alloc] init];
        return allWounds;
    }
    return nil;
}

- (CCSpriteBatchNode *)batchNode { 
    @synchronized(batchNode) {
        if (batchNode == nil)
            batchNode = [[CCSpriteBatchNode alloc] init];
        return batchNode;
    }
    return nil;
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [self createSpace]; 
        mouse = cpMouseNew(space);
        
        NSData *mScabs = [defaults objectForKey:@"allScabs"];
        if (mScabs != nil) {
            NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mScabs];
            if (oldSavedArray != nil) {
                self.allScabs = [[NSMutableArray alloc] init];
                
                for (ScabChunk *scab in oldSavedArray) {
                    [self.allScabs addObject:[[[ScabChunk alloc] initWithSpace:space location:scab.savedLocation filename:[NSString stringWithFormat:@"scab%d.png", scab.scabNo]] autorelease]];
                    //cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(self.rotation));
                }
            }
        }
        
        NSData *mWounds = [defaults objectForKey:@"allWounds"];
        if (mWounds != nil) {
            NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mWounds];
            if (oldSavedArray != nil) {
                self.allWounds = [[NSMutableArray alloc] init];
                
                for (Wound *wound in oldSavedArray) {
                    [self.allWounds addObject:[[[Wound alloc] initWithSpace:space location:wound.savedLocation filename:@"wound0.png"] autorelease]];
                    //cpBodySetAngle(body, CC_DEGREES_TO_RADIANS(self.rotation));
                }
            }
        }

        [self updateBackground];
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
        [self addChild:batchNode];

        if (![self.allScabs count]) {
            [self generateScabs];
        } else {
            [self displaySavedBoard];
        }
                                        
        [self scheduleUpdate];
    }
            
    return self;
}

- (cpSpace *)createSpace {    
    space = cpSpaceNew();
    space->gravity = ccp(0, -750);
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
    
    return space;
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

- (void)displaySavedBoard {    
    for (ScabChunk *scab in [self allScabs]) {
        [batchNode addChild:scab];        
    }
    
    for (Wound *wound in [self allWounds]) {
        [batchNode addChild:wound];        
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
    
    [scab setScabNo:scabIndex];
    [scab setPriority:priority];
    [scab setHealth:priority * 2];
    
    //[self clearLowerScabs:scab];
    [self.allScabs addObject:scab];
    
    return scab;
}

- (void)clearLowerScabs:(ScabChunk *)newScab {
    NSMutableArray *scabsToDelete = [[NSMutableArray alloc] init];
    for (ScabChunk *checkScab in [self allScabs]) {  
        if (cpSpacePointQueryFirst(space, checkScab.savedLocation, GRABABLE_MASK_BIT, 0)) {    
            //if (ccpDistance(newScab.position, checkScab.position) < 50.0) {
                [scabsToDelete addObject:checkScab];
            //}
        }
    }
    
    for (ScabChunk *deleteScab in scabsToDelete) {
        [self removeScab:deleteScab initing:YES];
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
    [self removeScab:chunk initing:NO];
}

- (void)createWound:(ScabChunk *)scab {    
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc]init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = scab.position;
    [self addChild:particles z:9];
    particles.autoRemoveOnFinish = YES;
    
    Wound *wound = [[[Wound alloc] initWithSpace:space location:scab.savedLocation filename:@"wound0.png"] autorelease];     
    wound.scabNo = scab.scabNo;
    
    [self.allWounds addObject:wound];
    [batchNode addChild:wound];        
}

- (void)removeScab:(ScabChunk *)scab initing:(bool)initing {
    [self.allScabs removeObject:scab];
    [scab destroy];
    
    //NSLog(@"CURR COUNT: %d   INITING: %@", [self.allScabs count], initing);
    if ([self.allScabs count] == 0 && !initing) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabcomplete.wav"];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Scab Complete!" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        title.position =  ccp(-100, 380);
        [title runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:ccp(160, 380)], [CCDelayTime actionWithDuration:2  ], [CCMoveTo actionWithDuration:0.3 position:ccp(500, 380)], [CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];
        
        [[[CCDirector sharedDirector] runningScene] addChild:title];
        
        NSLog(@"WOUND COUNT %d", [self.allWounds count]);
        for (Wound *wound in [self allWounds]) {
            NSLog(@"REMOVING A WOUND");
            [wound destroy];
        }
        
        allWounds = [[NSMutableArray alloc] init];
    }
}

- (void)resetBoard {
    [self updateBackground];
    [self generateScabs];
}

- (void)dealloc {
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [super dealloc];
}

@end