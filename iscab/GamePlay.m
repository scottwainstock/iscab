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
#import "AppDelegate.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30

@implementation GamePlay

@synthesize batchNode, allScabs, allWounds, allBlood, gravity, centerOfScab;

AppDelegate *app;
CGRect homeFrame;
bool endSequenceRunning;

- (NSMutableArray *)allBlood { 
    @synchronized(allBlood) {
        if (allBlood == nil)
            allBlood = [[NSMutableArray alloc] init];
        return allBlood;
    }
    return nil;
}

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
    if (!endSequenceRunning) {
        for (IScabSprite *sprite in batchNode.children) {
            [sprite update];

            if ([sprite respondsToSelector:@selector(health)] && sprite.position.y < 0) {
                [self removeScab:(ScabChunk *)sprite];
            }
        }
        
        for (CCMotionStreak *streak in self.allBlood) {
            if (arc4random() % 2 == 1) {
                CGPoint position = streak.position;
                
                if (self.gravity.x > 0) {
                    position.x = position.x + 1;
                } else if (self.gravity.x < 0) {
                    position.x = position.x - 1;
                } else if (self.gravity.y > 0) {
                    position.y = position.y + 1;
                } else if (self.gravity.y < 0) {
                    position.y = position.y - 1;
                }
                
                [streak setPosition:position];
            }                
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

- (void)didRotate {
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft)) {
        space->gravity = ccp(-750, 0);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        space->gravity = ccp(750, 0);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)) {
        space->gravity = ccp(0, -750);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) {
        space->gravity = ccp(0, 750);
    }

    self.gravity = space->gravity;
}

- (id)init {
    if((self=[super init])) {
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.isTouchEnabled = YES;
        endSequenceRunning = false;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [self createSpace]; 
        mouse = cpMouseNew(space);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didRotate)
                                              name:UIDeviceOrientationDidChangeNotification object:nil];
        
        NSData *mWounds = [defaults objectForKey:@"allWounds"];
        if (mWounds != nil) {
            NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mWounds];
            if (oldSavedArray != nil) {                
                for (Wound *savedWound in oldSavedArray) {
                    NSString *woundType = [GamePlay woundFrameNameForClean:savedWound.clean isBleeding:savedWound.bleeding scabNo:savedWound.scabNo];
                    Wound *wound = [[[Wound alloc] initWithSpriteFrameName:woundType] autorelease];
                    wound.position = savedWound.savedLocation;
                    wound.savedLocation = savedWound.savedLocation;
                    wound.scabNo = savedWound.scabNo;
                    wound.clean = savedWound.clean;
                    wound.bleeding = savedWound.bleeding;
                    
                    [self.allWounds addObject:wound];
                }
            }
        }
                
        NSData *mScabs = [defaults objectForKey:@"allScabs"];
        if (mScabs != nil) {
            NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mScabs];
            if (oldSavedArray != nil) {                
                for (ScabChunk *savedScab in oldSavedArray) {
                    ScabChunk *scabChunk = [[[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"scab%d.png", savedScab.scabNo]] autorelease];
                    scabChunk.position = savedScab.savedLocation;
                    scabChunk.savedLocation = savedScab.savedLocation;
                    scabChunk.scabNo = savedScab.scabNo;
                    
                    [self.allScabs addObject:scabChunk];
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
        centerOfScab = [self getCenterOfScab];
        
        NSLog(@"CENTER %@", NSStringFromCGPoint(centerOfScab));
    }
            
    return self;
}

- (CGPoint)getCenterOfScab {
    int x = 0;
    int y = 0;
    for (ScabChunk *scab in self.allScabs) {
        x += scab.savedLocation.x;
        y += scab.savedLocation.y;
    }
    
    return CGPointMake(x / [self.allScabs count], y / [self.allScabs count]);
}

- (cpSpace *)createSpace {    
    space = cpSpaceNew();
    space->gravity = ccp(0, -750);
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
    space->elasticIterations = 10;
    self.gravity = space->gravity;
    
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
    
    CCSprite *homeIcon = [CCSprite spriteWithFile:@"home-icon.png"];
    homeIcon.position = ccp(40, 40);
    homeFrame = homeIcon.textureRect;
    [self addChild:homeIcon z:2];
}

- (void)homeTapped {  
    [app saveState];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeUp transitionWithDuration:0.5f scene:[MainMenu scene]]];
}

- (void)displaySavedBoard {    
    for (ScabChunk *scab in [self allScabs]) {
        [self addChild:scab z:5];        
    }
    
    for (Wound *wound in [self allWounds]) {
        [self addChild:wound z:-1];        
    }
}

- (void)generateScabs {
    for (int x = 0; x < 200; x++) { 
        int scabIndex = arc4random() % 2;
                
        float startX = 75 + (arc4random() % 200);
        float startY = 125 + (arc4random() % 200);
                
        [self createScab:CGPointMake(startX, startY) type:@"light" scabIndex:(int)scabIndex havingPriority:1];
    }
       
    for (int x = 0; x < 100; x++) {
        float startX = 100 + (arc4random() % 100);
        float startY = 150 + (arc4random() % 100);
        int scabIndex = arc4random() % 2;
         
        [self createScab:CGPointMake(startX, startY) type:@"dark" scabIndex:(int)scabIndex havingPriority:2];
    }
}

- (ScabChunk *)createScab:(CGPoint)coordinates type:(NSString *)type scabIndex:(int)scabIndex havingPriority:(int)priority {
    ScabChunk *scab = [[[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", type, scabIndex]] autorelease];

    [scab setPosition:ccp(coordinates.x, coordinates.y)];
    [scab setSavedLocation:scab.position];
    [scab setScabNo:scabIndex];
    [scab setPriority:priority];
    [scab setHealth:priority * 2];
    
    [self clearLowerScabs:scab];
    [self.allScabs addObject:scab];
    [self addChild:scab z:5];
        
    return scab;
}

- (void)clearLowerScabs:(ScabChunk *)newScab {    
    NSMutableArray *scabsToDelete = [[NSMutableArray alloc] init];
    for (ScabChunk *checkScab in [self allScabs]) {
        if (ccpDistance(newScab.savedLocation, checkScab.savedLocation) < 5.0) {
            [scabsToDelete addObject:checkScab];
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
        
    if (CGRectContainsPoint(homeFrame, touchLocation)) {
        [self homeTapped];
    }
    
    NSLog(@"TOUCHED %@", NSStringFromCGPoint(touchLocation));
    
    for (ScabChunk *scabChunk in self.allScabs) {
        if (CGRectContainsPoint(scabChunk.boundingBox, touchLocation)) {
            if ([scabChunk health] > 0) {
                scabChunk.health -= 1;
            }
            
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % 3]];
        }
    }
    
    /*
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
*/
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    NSMutableArray *removedScabs = [NSMutableArray array];
    for (ScabChunk *scabChunk in self.allScabs) {
        if (CGRectContainsPoint(scabChunk.boundingBox, touchLocation)) {
            if ([scabChunk health] > 0) {
                return;
            }
            
            if (([scabChunk health] <= 0)) {
                for (ScabChunk *foo in self.allScabs) {
                    if (ccpDistance(foo.savedLocation, scabChunk.savedLocation) < 10.0) {
                        [removedScabs addObject:scabChunk];
                        [scabChunk ripOffScab];   
                    }
                }
            }
        }
    }
    
    for (ScabChunk *removedScab in removedScabs) {
        [self removeScab:removedScab initing:NO];
    }
    [removedScabs removeAllObjects];
    
/*    
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
    }*/
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

- (void)splatterBlood:(ScabChunk *)scab {
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc] init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = scab.position;
    [self addChild:particles z:9];
    particles.autoRemoveOnFinish = YES; 
    [particles release];
}

+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding scabNo:(int)scabNo {
    if (isClean) {
        return [NSString stringWithFormat:@"clean_skin%d.png", scabNo];
    } else if (!isClean && isBleeding) {
        return [NSString stringWithFormat:@"bloody_skin%d.png", scabNo];
    } else {
        return [NSString stringWithFormat:@"wound%d.png", scabNo];
    }
}

- (void)createWound:(ScabChunk *)scab cleanSkin:(bool)clean {    
    [self splatterBlood:scab];
            
    bool bleeding = (!clean && (arc4random() % (int)ceil(ccpDistance(centerOfScab, scab.savedLocation) * 0.10) == 1)) ? TRUE : FALSE;
    NSString *woundType = [GamePlay woundFrameNameForClean:clean isBleeding:bleeding scabNo:scab.scabNo];
    
    NSLog(@"TYPE %@", woundType);
    
    Wound *wound = [[[Wound alloc] initWithSpriteFrameName:woundType] autorelease];
    wound.position = scab.savedLocation;
    wound.savedLocation = scab.savedLocation;
    wound.scabNo = scab.scabNo;
    wound.clean = clean;
    wound.bleeding = bleeding;
    
    if (wound.bleeding) {
        for (Wound *savedWound in self.allWounds) {
            if (savedWound.bleeding && (ccpDistance(savedWound.savedLocation, wound.savedLocation) < 40.0) && (arc4random() % 10 == 1)) {
                CCMotionStreak *streak = [CCMotionStreak streakWithFade:10000.0f minSeg:1 image:@"blood_streak.png" width:10 length:10 color:ccc4(255,255,255,255)];
            
                streak.position = wound.savedLocation;
                [self addChild:streak z:10];
                [allBlood addObject:streak];
                [streak release];
            }
        }
    }
    
    [self.allWounds addObject:wound];
    [self addChild:wound z:-1];
}

- (void)removeScab:(ScabChunk *)scab initing:(bool)initing {
    [self.allScabs removeObject:scab];
    [scab destroy];
    
    if (([self.allScabs count] == 0) && !initing) {
        endSequenceRunning = true;
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabcomplete.wav"];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Scab Complete!" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
        title.position =  ccp(-100, 380);
        [title runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:ccp(160, 380)], [CCDelayTime actionWithDuration:2  ], [CCMoveTo actionWithDuration:0.3 position:ccp(500, 380)], [CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];
        
        [[[CCDirector sharedDirector] runningScene] addChild:title];
    }
}

- (void)resetBoard {
    for (Wound *wound in [self allWounds]) {
        [wound destroy];
    }
    allWounds = [[NSMutableArray alloc] init];

    for (CCMotionStreak *streak in [self allBlood]) {
        [streak removeFromParentAndCleanup:YES];
    }
    allBlood = [[NSMutableArray alloc] init];
      
    [self updateBackground];
    [self generateScabs];
    endSequenceRunning = false;
}

- (void)dealloc {
    [super dealloc];
    /*
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [batchNode release];
    [allScabs release];
    [allWounds release];
    [allBlood release];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];*/
}

@end