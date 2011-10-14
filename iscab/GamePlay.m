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
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "JarScene.h"
#import "CCParticleMyBlood.h"
#import "AppDelegate.h"
#import "drawSpace.h"
#import "cpSpace.h"
#import "cpShape.h"

#define DEFAULT_FONT_NAME @"ITC Avant Garde Gothic Std"
#define DEFAULT_FONT_SIZE 30
#define NUM_SHAPES 4
#define NUM_BACKGROUNDS 8
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_REMOVAL 10.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCABS 10

@implementation GamePlay

@synthesize batchNode, allScabs, allWounds, allBlood, looseScabs, gravity, centerOfScab, skinBackground, skinBackgroundOffsets, sizeOfMoveableScab, moveableScab;

AppDelegate *app;
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

- (NSMutableArray *)looseScabs { 
    @synchronized(looseScabs) {
        if (looseScabs == nil)
            looseScabs = [[NSMutableArray alloc] init];
        return looseScabs;
    }
    return nil;
}

- (void)update:(ccTime)dt {
    cpSpaceStep(space, dt);
    if (!endSequenceRunning) {
        NSMutableArray *spritesToDelete = [[NSMutableArray alloc] init];

        for (IScabSprite *sprite in batchNode.children) {
            [sprite update];

            if (sprite.position.y < 0) {
                [spritesToDelete addObject:sprite];
            }
        }
        
        for (IScabSprite *deleteSprite in spritesToDelete) {
            if (deleteSprite->body) {
                [looseScabs removeObject:deleteSprite];
            }
            
            [batchNode removeChild:deleteSprite cleanup:YES];
            [deleteSprite destroy];
        }
        
        [spritesToDelete release];

        
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
        space->gravity = ccp(-GRAVITY_FACTOR, 0);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        space->gravity = ccp(GRAVITY_FACTOR, 0);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)) {
        space->gravity = ccp(0, -GRAVITY_FACTOR);
    } else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown)) {
        space->gravity = ccp(0, GRAVITY_FACTOR);
    }

    self.gravity = space->gravity;
}

- (id)init {
    if((self=[super init])) {
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.isTouchEnabled = YES;
        endSequenceRunning = false;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [self setupSkinBackgroundOffsets];
        
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
                    ScabChunk *scabChunk = [[[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", savedScab.type, savedScab.scabNo]] autorelease];
                    scabChunk.position = savedScab.savedLocation;
                    scabChunk.savedLocation = savedScab.savedLocation;
                    scabChunk.type = savedScab.type;
                    scabChunk.scabNo = savedScab.scabNo;
                    
                    [self.allScabs addObject:scabChunk];
                }
            }
        }

        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
        [self addChild:batchNode];
                 
        if (![self.allScabs count]) {
            [self updateBackground:nil];
            [self generateScabs];
        } else {
            [self updateBackground:[defaults valueForKey:@"skinBackground"]];
            [self displaySavedBoard];
        }
        
        [self scheduleUpdate];
        centerOfScab = [self getCenterOfScab];
        
        NSLog(@"CENTER %@", NSStringFromCGPoint(centerOfScab));
    }
            
    return self;
}

- (void)setupSkinBackgroundOffsets {
    self.skinBackgroundOffsets = [[NSMutableDictionary alloc] init];
    [self.skinBackgroundOffsets setObject:@"25" forKey:@"skin_background0.png"];
    [self.skinBackgroundOffsets setObject:@"350" forKey:@"skin_background1.png"];
    [self.skinBackgroundOffsets setObject:@"100" forKey:@"skin_background2.png"];
    [self.skinBackgroundOffsets setObject:@"175" forKey:@"skin_background3.png"];
    [self.skinBackgroundOffsets setObject:@"175" forKey:@"skin_background4.png"];
    [self.skinBackgroundOffsets setObject:@"75" forKey:@"skin_background5.png"];
    [self.skinBackgroundOffsets setObject:@"225" forKey:@"skin_background6.png"];
    [self.skinBackgroundOffsets setObject:@"50" forKey:@"skin_background7.png"];
    [self.skinBackgroundOffsets setObject:@"50" forKey:@"skin_background8.png"];
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
    space->gravity = ccp(0, -GRAVITY_FACTOR);
    cpSpaceResizeStaticHash(space, 400, 200);
    cpSpaceResizeActiveHash(space, 200, 200);
    space->elasticIterations = 10;
    self.gravity = space->gravity;
    
    return space;
}

- (void)updateBackground:(NSString *)newSkinBackground {
    [(CCSprite *)[self getChildByTag:777] removeFromParentAndCleanup:YES];

    NSLog(@"SKIN BACKGROUND %@", newSkinBackground);
    
    if (newSkinBackground == nil) {
        int bgIndex = arc4random() % NUM_BACKGROUNDS;
        newSkinBackground = [NSString stringWithFormat:@"skin_background%d.png", bgIndex];
    }
    
    CCSprite *bg = [CCSprite spriteWithFile:newSkinBackground];
    bg.tag = 777;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    self.skinBackground = newSkinBackground;
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
    int yOffset = [[skinBackgroundOffsets objectForKey:skinBackground] intValue];
    
    NSLog(@"BG OFFSET: %d", yOffset);
    
    CGPoint centerOfScab = CGPointMake(75 + (arc4random() % 150), yOffset + (arc4random() % 150));
    
    for (int x = 0; x < 2000; x++) { 
        int scabIndex = arc4random() % NUM_SHAPES;
                
        float startX = 75 + (arc4random() % 150);
        float startY = yOffset + (arc4random() % 150);
                
        [self createScab:CGPointMake(startX, startY) type:@"light" scabIndex:(int)scabIndex havingPriority:1];
    }
         
    for (int x = 0; x < 400; x++) {
        int scabIndex = arc4random() % NUM_SHAPES;
        
        float startX = 100 + (arc4random() % 75);
        float startY = yOffset + (arc4random() % 75);
         
        [self createScab:CGPointMake(startX, startY) type:@"dark" scabIndex:(int)scabIndex havingPriority:2];
    }
}

- (ScabChunk *)createScab:(CGPoint)coordinates type:(NSString *)type scabIndex:(int)scabIndex havingPriority:(int)priority {
    ScabChunk *scab = [[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", type, scabIndex]];

    [scab setPosition:ccp(coordinates.x, coordinates.y)];
    [scab setSavedLocation:scab.position];
    [scab setScabNo:scabIndex];
    [scab setPriority:priority];
    [scab setType:type];
    [scab setHealth:priority * 2];
    
    //[self clearLowerScabs:scab];
    [self.allScabs addObject:scab];
    [batchNode addChild:scab z:5];
    
    [scab release];
        
    return scab;
}

- (void)clearLowerScabs:(ScabChunk *)newScab {       
    NSMutableArray *scabsToDelete = [[NSMutableArray alloc] init];
    for (ScabChunk *checkScab in [self allScabs]) {
        if (ccpDistance(newScab.savedLocation, checkScab.savedLocation) < 1.75) {
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
    sizeOfMoveableScab = 1;
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    for (ScabChunk *scabChunk in self.allScabs) {
        if (ccpDistance(scabChunk.savedLocation, touchLocation) < MINIMUM_DISTANCE_FOR_CLOSE_SCAB_REMOVAL) {
            if (self.moveableScab == nil || self.moveableScab.position.y < 0) {
                moveableScab = [[IScabSprite alloc] initWithSpace:space location:touchLocation filename:[NSString stringWithFormat:@"%@_scab%d.png", scabChunk.type, scabChunk.scabNo] shapeNo:scabChunk.scabNo];
                [batchNode addChild:moveableScab];
            }
        }
    }

    cpMouseGrab(mouse, touchLocation, false);
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];

    cpMouseMove(mouse, touchLocation);
    
    NSMutableArray *removedScabs = [NSMutableArray array];
    for (ScabChunk *scabChunk in self.allScabs) {
        if (ccpDistance(scabChunk.savedLocation, touchLocation) < MINIMUM_DISTANCE_FOR_CLOSE_SCAB_REMOVAL) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];

            if ([scabChunk health] > 0) {
                scabChunk.health -= 1;
            }
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                [self addScabChunk:scabChunk fromLocation:touchLocation];
                
                if ([looseScabs count] < MAXIMUM_NUMBER_OF_LOOSE_SCABS) {
                    IScabSprite *looseScab = [[IScabSprite alloc] initWithSpace:space location:scabChunk.savedLocation filename:[NSString stringWithFormat:@"%@_scab%d.png", scabChunk.type, scabChunk.scabNo] shapeNo:scabChunk.scabNo];
                    
                    [self.looseScabs addObject:looseScab];
                    [batchNode addChild:looseScab];
                    [looseScab release];
                }                
            }
        }
    }
    
    for (ScabChunk *removedScab in removedScabs) {
        [self removeScab:removedScab initing:NO];
    }
    [removedScabs removeAllObjects];    
}

- (void)addScabChunk:(ScabChunk *)scabChunk fromLocation:(CGPoint)location {
    float offsetX = -sizeOfMoveableScab + (arc4random() % (sizeOfMoveableScab * 2));
    float offsetY = -sizeOfMoveableScab + (arc4random() % (sizeOfMoveableScab * 2));
    CGPoint offsetLocation = CGPointMake(location.x + offsetX, location.y + offsetY);
    cpShape *foundShape = cpSpacePointQueryFirst(space, offsetLocation, GRABABLE_MASK_BIT, 0);
    if (foundShape) {
        CCSprite *newMoveableScabPiece = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", scabChunk.type, scabChunk.scabNo]];
        
        
        [newMoveableScabPiece setPosition:CGPointMake(arc4random() % sizeOfMoveableScab, arc4random() % sizeOfMoveableScab)];
        [moveableScab addChild:newMoveableScabPiece];
                 
        sizeOfMoveableScab += 1;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"TOUCH ENDED");
    cpMouseRelease(mouse);

    /*
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
     */
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
}

- (void)removeScab:(ScabChunk *)chunk {
    [self removeScab:chunk initing:NO];
}

- (void)splatterBlood:(ScabChunk *)scab {
    return;
    
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
        
    Wound *wound = [[Wound alloc] initWithSpriteFrameName:woundType];
    wound.position = scab.savedLocation;
    wound.savedLocation = scab.savedLocation;
    wound.scabNo = scab.scabNo;
    wound.clean = clean;
    wound.bleeding = bleeding;
    
    if (wound.bleeding) {
        for (Wound *savedWound in self.allWounds) {
            if (savedWound.bleeding && (ccpDistance(savedWound.savedLocation, wound.savedLocation) < 5.0) && (arc4random() % 100 == 1)) {
                CCMotionStreak *streak = [[CCMotionStreak streakWithFade:10000.0f minSeg:1 image:@"blood_streak.png" width:10 length:10 color:ccc4(255,255,255,255)] autorelease];
            
                streak.position = wound.savedLocation;
                [self addChild:streak z:10];
                [allBlood addObject:streak];
                
                [streak release];
            }
        }
    }
    
    [self.allWounds addObject:wound];
    [batchNode addChild:wound z:-1];

    [wound release];
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
        [streak removeFromParentAndCleanup:NO];
    }
    allBlood = nil;
      
    [self updateBackground:nil];
    [self generateScabs];
    endSequenceRunning = false;
}

- (void)homeTapped:(CCMenuItem  *)menuItem { 
    [super homeTapped:menuItem];
    [app saveState];
}

- (void)jarTapped:(CCMenuItem  *)menuItem {
    [super jarTapped:menuItem];
    [app saveState];
}

- (void)dealloc {
    [super dealloc];
    /*
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [skinBackground release];
    [skinBackgroundOffsets release];
    [batchNode release];
    [allScabs release];
    [allWounds release];
    [allBlood release];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];*/
}

@end