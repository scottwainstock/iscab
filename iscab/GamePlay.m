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
#define NUM_SHAPE_TYPES 4
#define NUM_BACKGROUNDS 8
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL 10.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS 10
#define NUM_INDIVIDUAL_SCABS 10
#define NUM_DARK_PATCHES 4

@implementation GamePlay

@synthesize batchNode, allScabChunks, allWounds, allBlood, looseScabChunks, gravity, centerOfAllScabs, skinBackground, skinBackgroundOffsets, sizeOfMoveableScab, moveableScab;

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

- (NSMutableArray *)allScabChunks { 
    @synchronized(allScabChunks) {
        if (allScabChunks == nil)
            allScabChunks = [[NSMutableArray alloc] init];
        return allScabChunks;
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

- (NSMutableArray *)looseScabChunks { 
    @synchronized(looseScabChunks) {
        if (looseScabChunks == nil)
            looseScabChunks = [[NSMutableArray alloc] init];
        return looseScabChunks;
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
                [looseScabChunks removeObject:deleteSprite];
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.isTouchEnabled = YES;
        endSequenceRunning = false;
        
        [self setupSkinBackgroundOffsets];
        
        [self createSpace]; 
        mouse = cpMouseNew(space);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didRotate)
                                              name:UIDeviceOrientationDidChangeNotification object:nil];
        
        NSLog(@"SCREEN WIDTH: %d HEIGHT %d", screenWidth, screenHeight);
        
        [self initializeSprites];
         
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"scabs.png"];
        [self addChild:batchNode];
                 
        if (![self.allScabChunks count]) {
            NSLog(@"GENERATING NEW BOARD");
            [self updateBackground:nil];
            [self generateScabs];
        } else {
            NSLog(@"USING EXISTING BOARD");
            [self updateBackground:[defaults valueForKey:@"skinBackground"]];
            [self displaySavedBoard];
        }
        
        [self scheduleUpdate];
        centerOfAllScabs = [self getCenterOfAllScabs];
        
        NSLog(@"CENTER OF ALL SCABS: %@", NSStringFromCGPoint(centerOfAllScabs));
    }
            
    return self;
}

- (void)initializeSprites {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

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
    
    NSData *mScabs = [defaults objectForKey:@"allScabChunks"];
    if (mScabs != nil) {
        NSMutableArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:mScabs];
        if (oldSavedArray != nil) {                
            for (ScabChunk *savedScab in oldSavedArray) {
                ScabChunk *scabChunk = [[[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", savedScab.type, savedScab.scabNo]] autorelease];
                scabChunk.position = savedScab.savedLocation;
                scabChunk.savedLocation = savedScab.savedLocation;
                scabChunk.type = savedScab.type;
                scabChunk.scabNo = savedScab.scabNo;
                
                [self.allScabChunks addObject:scabChunk];
            }
        }
    }
}

- (void)setupSkinBackgroundOffsets {
    self.skinBackgroundOffsets = [[NSMutableDictionary alloc] init];
    [self.skinBackgroundOffsets setObject:@"140" forKey:@"skin_background0.png"];
    [self.skinBackgroundOffsets setObject:[NSString stringWithFormat:@"%d", screenHeight] forKey:@"skin_background1.png"];
    [self.skinBackgroundOffsets setObject:@"275" forKey:@"skin_background2.png"];
    [self.skinBackgroundOffsets setObject:[NSString stringWithFormat:@"%d", screenHeight] forKey:@"skin_background3.png"];
    [self.skinBackgroundOffsets setObject:[NSString stringWithFormat:@"%d", screenHeight] forKey:@"skin_background4.png"];
    [self.skinBackgroundOffsets setObject:@"260" forKey:@"skin_background5.png"];
    [self.skinBackgroundOffsets setObject:@"390" forKey:@"skin_background6.png"];
    [self.skinBackgroundOffsets setObject:@"205" forKey:@"skin_background7.png"];
    [self.skinBackgroundOffsets setObject:@"235" forKey:@"skin_background8.png"];
}

- (CGPoint)getCenterOfAllScabs {
    NSLog(@"TOTAL NUMBER OF SCAB CHUNKS: %d", [self.allScabChunks count]);
    int x = 0;
    int y = 0;
    for (ScabChunk *scab in self.allScabChunks) {
        x += scab.savedLocation.x;
        y += scab.savedLocation.y;
    }
    
    return CGPointMake(x / [self.allScabChunks count], y / [self.allScabChunks count]);
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
    
    if (newSkinBackground == nil) {
        int bgIndex = arc4random() % NUM_BACKGROUNDS;
        newSkinBackground = [NSString stringWithFormat:@"skin_background%d.png", bgIndex];
    }
    
    NSLog(@"SKIN BACKGROUND %@", newSkinBackground);
    
    CCSprite *bg = [CCSprite spriteWithFile:newSkinBackground];
    bg.tag = 777;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    self.skinBackground = newSkinBackground;
}

- (void)displaySavedBoard {    
    for (ScabChunk *scab in [self allScabChunks]) {
        [self addChild:scab z:5];        
    }
    
    for (Wound *wound in [self allWounds]) {
        [self addChild:wound z:-1];        
    }
}

- (CGPoint)getScabChunkCenterFrom:(CGPoint)origin scabBoundingRect:(CGRect)scabBoundingRect maxDistanceToXEdge:(int)maxDistanceToXEdge maxDistanceToYEdge:(int)maxDistanceToYEdge {
    CGPoint scabChunkCenter = CGPointMake(
                                          (int)origin.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
                                          (int)origin.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
                                          );
    
    if (
        CGRectContainsPoint([UIScreen mainScreen].bounds, scabChunkCenter) &&  // is inside the screen
        CGRectContainsPoint(
            CGRectMake(0, 0, screenWidth, [[skinBackgroundOffsets objectForKey:skinBackground] intValue]), 
            scabChunkCenter
        ) && // is inside background offset boundaries
        CGRectContainsPoint(scabBoundingRect, scabChunkCenter) && // is inside scab boundaries
        !CGRectContainsPoint(self.homeButton.boundingBox, scabChunkCenter) && // is not inside the home icon
        !CGRectContainsPoint(self.jarButton.boundingBox, scabChunkCenter) // is not inside the jar icon
    ) {
        return scabChunkCenter;
    }

    return CGPointZero;
}

- (void)generateScabs {
    int backgroundYOffset = [[skinBackgroundOffsets objectForKey:skinBackground] intValue];
    NSLog(@"BACKGROUND Y OFFSET IS: %d", backgroundYOffset);

    int numScabs = (arc4random() % NUM_INDIVIDUAL_SCABS) + 1;
    NSLog(@"NUMBER OF SCABS TO DRAW: %d", numScabs);
    
    for (int x = 0; x < numScabs; x++) {
        int scabYOffset = (arc4random() % backgroundYOffset) + 1;
        
        CGPoint scabOrigin = CGPointMake(arc4random() % screenWidth, scabYOffset);
        CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, arc4random() % 150, 50 + (arc4random() % scabYOffset));
        CGPoint scabCenter = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
        int maxDistanceToXEdge = (scabCenter.x - scabOrigin.x) + 1;
        int maxDistanceToYEdge = (scabCenter.y - scabOrigin.y) + 1;
        
        NSLog(@"SCAB ORIGIN: %@", NSStringFromCGPoint(scabOrigin));
        NSLog(@"CENTER OF SCAB: %@", NSStringFromCGPoint(scabCenter));
        
        int numScabChunks = scabBoundary.size.height + scabBoundary.size.width;
        NSLog(@"NUM SCAB CHUNKS IN THIS SCAB: %d", numScabChunks);
        
        for (int x = 0; x < numScabChunks; x++) { 
            int scabChunkIndex = arc4random() % NUM_SHAPE_TYPES;
            CGPoint scabChunkCenter = [self getScabChunkCenterFrom:scabCenter scabBoundingRect:scabBoundary maxDistanceToXEdge:maxDistanceToXEdge maxDistanceToYEdge:maxDistanceToYEdge];
                        
            if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero)) {
                [self createScabChunk:scabChunkCenter type:@"light" scabIndex:(int)scabChunkIndex havingPriority:1];
            }
        }
        
        int numDarkPatches = (arc4random() % NUM_DARK_PATCHES);
        for (int x = 0; x < numDarkPatches; x++) {
            CGPoint patchOrigin = CGPointMake(
                (int)scabCenter.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
                (int)scabCenter.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
            );

            for (int x = 0; x < (numScabChunks / 4); x++) {
                int scabChunkIndex = arc4random() % NUM_SHAPE_TYPES;
                CGPoint scabChunkCenter = [self getScabChunkCenterFrom:patchOrigin scabBoundingRect:scabBoundary maxDistanceToXEdge:maxDistanceToXEdge maxDistanceToYEdge:maxDistanceToYEdge];

                if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero)) {
                    [self createScabChunk:scabChunkCenter type:@"dark" scabIndex:(int)scabChunkIndex havingPriority:2];
                }
            }
        }
    }
}

- (ScabChunk *)createScabChunk:(CGPoint)coordinates type:(NSString *)type scabIndex:(int)scabIndex havingPriority:(int)priority {
    ScabChunk *scabChunk = [[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", type, scabIndex]];

    [scabChunk setPosition:ccp(coordinates.x, coordinates.y)];
    [scabChunk setSavedLocation:scabChunk.position];
    [scabChunk setScabNo:scabIndex];
    [scabChunk setPriority:priority];
    [scabChunk setType:type];
    [scabChunk setHealth:priority * 2];
    
    //[self clearLowerScabs:scab];
    [self.allScabChunks addObject:scabChunk];
    [batchNode addChild:scabChunk z:5];
    
    [scabChunk release];
        
    return scabChunk;
}

- (void)clearLowerScabChunks:(ScabChunk *)newScabChunk {       
    NSMutableArray *scabChunksToDelete = [[NSMutableArray alloc] init];
    for (ScabChunk *checkScabChunk in [self allScabChunks]) {
        if (ccpDistance(newScabChunk.savedLocation, checkScabChunk.savedLocation) < 1.75) {
            [scabChunksToDelete addObject:checkScabChunk];
        }
    }
    
    for (ScabChunk *deleteScabChunk in scabChunksToDelete) {
        [self removeScabChunk:deleteScabChunk initing:YES];
    }
    
    [scabChunksToDelete release];
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    sizeOfMoveableScab = 1;
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    for (ScabChunk *scabChunk in self.allScabChunks) {
        if (ccpDistance(scabChunk.savedLocation, touchLocation) < MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL) {
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
    for (ScabChunk *scabChunk in self.allScabChunks) {
        if (ccpDistance(scabChunk.savedLocation, touchLocation) < MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];

            if ([scabChunk health] > 0) {
                scabChunk.health -= 1;
            }
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                [self addScabChunk:scabChunk fromLocation:touchLocation];
                
                if ([looseScabChunks count] < MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS) {
                    IScabSprite *looseScab = [[IScabSprite alloc] initWithSpace:space location:scabChunk.savedLocation filename:[NSString stringWithFormat:@"%@_scab%d.png", scabChunk.type, scabChunk.scabNo] shapeNo:scabChunk.scabNo];
                    
                    [self.looseScabChunks addObject:looseScab];
                    [batchNode addChild:looseScab];
                    [looseScab release];
                }                
            }
        }
    }
    
    for (ScabChunk *removedScabChunk in removedScabs) {
        [self removeScabChunk:removedScabChunk initing:NO];
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
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
}

- (void)splatterBlood:(ScabChunk *)scabChunk {
    return;
    
    CCParticleMyBlood *particles = [[CCParticleMyBlood alloc] init];
    particles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blood.png"];
    particles.position = scabChunk.position;
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
            
    bool bleeding = (!clean && (arc4random() % (int)ceil(ccpDistance(centerOfAllScabs, scab.savedLocation) * 0.10) == 1)) ? TRUE : FALSE;
    
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

- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing {
    [self.allScabChunks removeObject:scabChunk];
    [scabChunk destroy];
    
    if (([self.allScabChunks count] == 0) && !initing) {
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