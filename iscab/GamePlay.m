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
#import "Scab.h"
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "JarScene.h"
#import "CCParticleMyBlood.h"
#import "AppDelegate.h"
#import "drawSpace.h"
#import "cpSpace.h"
#import "cpShape.h"

static const ccColor3B ccSCABGLOW={255,105,180};

@implementation GamePlay

@synthesize allBlood, looseScabChunks, gravity, skinBackgroundBoundaries, sizeOfMoveableScab, moveableScab, endSequenceRunning;

AppDelegate *app;

- (NSMutableArray *)allBlood { 
    @synchronized(allBlood) {
        if (allBlood == nil)
            allBlood = [[NSMutableArray alloc] init];
        return allBlood;
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

- (NSMutableArray *)activeScabChunks {
    NSMutableArray *scabChunks = [[NSMutableArray alloc] init];
    for (Scab *scab in app.scabs) {
        [scabChunks addObjectsFromArray:scab.scabChunks];
    }
    
    //[scabChunks release];
    return scabChunks;
}

- (void)update:(ccTime)delta {
    cpSpaceStep(space, delta);
    
    if (!endSequenceRunning) {
        NSMutableArray *spritesToDelete = [[NSMutableArray alloc] init];
        
        for (IScabSprite *sprite in app.batchNode.children) {
            [sprite update];

            if ([sprite isOffscreen])
                [spritesToDelete addObject:sprite];
        }
        
        for (IScabSprite *deleteSprite in spritesToDelete) {
            if (deleteSprite->body)
                [looseScabChunks removeObject:deleteSprite];
            
            [app.batchNode removeChild:deleteSprite cleanup:YES];
            [deleteSprite destroy];
        }
        
        //[spritesToDelete release];
        
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
    [scene addChild:layer z:0 tag:100];
    
    return scene;
}

- (void)draw {
    drawSpaceOptions options = {
        0, 0, 1, 1.0f, 0.0f, 1.0f
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
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.isTouchEnabled = YES;
        endSequenceRunning = false;
        
        [self setupSkinBackgroundBoundaries];
        
        [self createSpace];
        mouse = cpMouseNew(space);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
                    
        [self addChild:app.batchNode];
        
        NSData *mScabs = [defaults objectForKey:@"scabs"];
        if (mScabs != nil)
            [app.scabs addObjectsFromArray:(NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:mScabs]];
                 
        if (![app.scabs count]) {
            NSLog(@"GENERATING NEW BOARD");
            [self updateBackground:nil];
            [self generateScabs];
        } else {
            NSLog(@"USING EXISTING BOARD");
            [self updateBackground:[defaults stringForKey:@"skinBackground"]];
            
            NSLog(@"NUMBER OF SCABS: %d", [app.scabs count]);
            for (Scab *scab in app.scabs) {
                [scab displaySprites];
            }
        }
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self scheduleUpdate];
    }
            
    return self;
}

- (void)generateScabs {    
    CGRect backgroundBoundary = [[skinBackgroundBoundaries objectForKey:app.skinBackground] CGRectValue];
    
    int numScabs = (arc4random() % NUM_INDIVIDUAL_SCABS) + 1;
    for (int x = 0; x < numScabs; x++) {
        [app.scabs addObject:[[Scab alloc] createWithBackgroundBoundary:backgroundBoundary]];
    }
}

- (void)setupSkinBackgroundBoundaries {
    self.skinBackgroundBoundaries = [[NSMutableDictionary alloc] init];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(80, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - 80 -X_SCAB_BORDER_BOUNDARY, 165)] forKey:@"skin_background0.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 275)] forKey:@"skin_background1.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), app.screenHeight - (Y_SCAB_BORDER_BOUNDARY * 2))] forKey:@"skin_background2.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), app.screenHeight - (Y_SCAB_BORDER_BOUNDARY * 2))] forKey:@"skin_background3.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 225)] forKey:@"skin_background4.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, 60, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 320)] forKey:@"skin_background5.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 205)] forKey:@"skin_background6.png"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(50, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - 100, 235)] forKey:@"skin_background7.png"];
}

- (void)updateBackground:(NSString *)newSkinBackground {
    [(CCSprite *)[self getChildByTag:BACKGROUND_IMAGE_TAG_ID] removeFromParentAndCleanup:YES];
    
    if (newSkinBackground == nil)
        newSkinBackground = [NSMutableString stringWithFormat:@"skin_background%d.png", arc4random() % NUM_BACKGROUNDS];
    
    NSLog(@"NEW SKIN BACKGROUND %@", newSkinBackground);
    
    CCSprite *bg = [CCSprite spriteWithFile:newSkinBackground];
    bg.tag = BACKGROUND_IMAGE_TAG_ID;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    app.skinBackground = [newSkinBackground copy];
}

- (void)addToLooseScabChunk:(ScabChunk *)scabChunk fromLocation:(CGPoint)location {
    float offsetX = -sizeOfMoveableScab + (arc4random() % (sizeOfMoveableScab * 2));
    float offsetY = -sizeOfMoveableScab + (arc4random() % (sizeOfMoveableScab * 2));
    CGPoint offsetLocation = CGPointMake(location.x + offsetX, location.y + offsetY);
    cpShape *foundShape = cpSpacePointQueryFirst(space, offsetLocation, GRABABLE_MASK_BIT, 0);
    if (foundShape) {
        CCSprite *newMoveableScabPiece = [CCSprite spriteWithSpriteFrameName:[scabChunk filename]];
        
        [newMoveableScabPiece setPosition:CGPointMake(arc4random() % sizeOfMoveableScab, arc4random() % sizeOfMoveableScab)];
        [moveableScab addChild:newMoveableScabPiece];
                 
        sizeOfMoveableScab += 1;
    }
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

- (void)addScabToJar:(Scab *)scab {
    NSLog(@"SCORE: %d", [scab pointValue]);
    Jar *currentJar = [app currentJar];
    currentJar.numScabLevels += [scab pointValue];
    if (currentJar.numScabLevels > MAX_NUM_SCAB_LEVELS)
        currentJar.numScabLevels = MAX_NUM_SCAB_LEVELS;

    CCSprite *scorePopup = [CCSprite spriteWithFile:@"scab_added.png"];
    [scorePopup setPosition:ccp(195, 40)];
    [scorePopup runAction:[CCFadeOut actionWithDuration:4]]; 
    [self addChild:scorePopup z:100];
}

- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing {
    Scab *scab = scabChunk.scab;
    [scabChunk destroy];

    if ([scab isComplete])
        [self addScabToJar:scab];

    if ([self isBoardCompleted] && !initing) {
        endSequenceRunning = true;
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabcomplete.wav"];
        
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Scab Complete!" fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE * 3];
        title.position =  ccp(-100, 380);
        [title runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.3 position:ccp(160, 380)], [CCDelayTime actionWithDuration:2  ], [CCMoveTo actionWithDuration:0.3 position:ccp(500, 380)], [CCDelayTime actionWithDuration:1], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];
        
        [[[CCDirector sharedDirector] runningScene] addChild:title];
    }
}

- (bool)isBoardCompleted {
    for (Scab *scab in app.scabs) {
        if (![scab isComplete])
            return false;
    }
    
    return true;
}

- (void)resetBoard {
    for (Scab *scab in app.scabs) {
        [scab reset];
    }
    
    for (CCMotionStreak *streak in [self allBlood]) {
        [streak removeFromParentAndCleanup:NO];
    }
    allBlood = nil;
    
    [app.scabs removeAllObjects];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self updateBackground:nil];
    [self generateScabs];
    endSequenceRunning = false;
}

- (void)homeTapped:(CCMenuItem  *)menuItem { 
    [super homeTapped:menuItem];
    [app saveState];

    for (Scab *scab in app.scabs) {
        [scab reset];
    }
}

- (void)jarTapped:(CCMenuItem  *)menuItem {
    [super jarTapped:menuItem];
    [app saveState];
    
    for (Scab *scab in app.scabs) {
        [scab reset];
    }
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    sizeOfMoveableScab = 1;
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGRect touchRect = CGRectMake(touchLocation.x, touchLocation.y, MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL, MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL);
    
    for (ScabChunk *scabChunk in [self activeScabChunks]) {
        if (CGRectContainsPoint(touchRect, scabChunk.savedLocation)) {
            if (self.moveableScab == nil || [self.moveableScab isOffscreen]) {
                moveableScab = [[IScabSprite alloc] initWithSpace:space location:touchLocation filename:[scabChunk filename] shapeNo:scabChunk.scabChunkNo];
                [app.batchNode addChild:moveableScab];
            }
        }
    }
    
    cpMouseGrab(mouse, touchLocation, false);
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGRect touchRect = CGRectMake(touchLocation.x - (MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL / 2), touchLocation.y - (MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL /2), MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL, MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL);
    
    cpMouseMove(mouse, touchLocation);
    
    NSMutableArray *removedScabs = [NSMutableArray array];
    for (ScabChunk *scabChunk in [self activeScabChunks]) {
        if (CGRectContainsPoint(touchRect, scabChunk.savedLocation)) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];
            
            if ([scabChunk health] > 0)
                scabChunk.health -= 1;
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                if ([scabChunk.scab isOverpicked] && ![scabChunk.scab isOverpickWarningIssued])
                    [self warnAboutOverpicking:scabChunk.scab];
                
                [self addToLooseScabChunk:scabChunk fromLocation:touchLocation];
                
                if ([looseScabChunks count] < MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS) {
                    IScabSprite *looseScab = [[IScabSprite alloc] initWithSpace:space location:scabChunk.position filename:[scabChunk filename] shapeNo:scabChunk.scabChunkNo];
                    
                    [self.looseScabChunks addObject:looseScab];
                    [app.batchNode addChild:looseScab];
                    //[looseScab release];
                }              
            }
        }
    }
    
    for (ScabChunk *removedScabChunk in removedScabs) {
        if (removedScabChunk != nil) {
            [self removeScabChunk:removedScabChunk initing:NO];
        }
    }
    [removedScabs removeAllObjects];
}

- (void)warnAboutOverpicking:(Scab *)scabToWarnFor {
    CCLabelTTF *overpickWarning = [CCLabelTTF labelWithString:@"Don't over-pick!\nIt'll take longer to heal and longer to fill up you scab jar!" dimensions:CGSizeMake(200.0f, 35.0f) alignment:UITextAlignmentCenter fontName:DEFAULT_FONT_NAME fontSize:DEFAULT_FONT_SIZE];
    [overpickWarning setColor:ccBLACK];
    [overpickWarning setPosition:ccp(195, 400)];
    [overpickWarning runAction:[CCFadeOut actionWithDuration:8]]; 
    [self addChild:overpickWarning z:100];
    [scabToWarnFor setIsOverpickWarningIssued:YES];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"TOUCH ENDED");
    cpMouseRelease(mouse);
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
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

- (void)dealloc {
    [super dealloc];
    /*
    cpMouseFree(mouse);
    cpSpaceFree(space);
    [skinBackground release];
    [skinBackgroundBoundaries release];
    [batchNode release];
    [allScabs release];
    [allWounds release];
    [allBlood release];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];*/
}

@end