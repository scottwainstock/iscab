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
#import "GameCenterBridge.h"
#import "SpecialScabs.h"

static const ccColor3B ccSCABGLOW={255,105,180};

@implementation GamePlay

@synthesize allBlood, looseScabChunks, gravity, skinBackgroundBoundaries, endSequenceRunning;

AppDelegate *app;

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
    [scene setTag:GAMEPLAY_SCENE_TAG];
    GamePlay *layer = [GamePlay node];
    [scene addChild:layer z:0 tag:GAMEPLAY_SCENE_TAG];
    
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
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
                    
        [self addChild:app.batchNode];
        
        if (![defaults objectForKey:@"scabs"]) {
            NSLog(@"GENERATING NEW BOARD");
            [self updateBackground:nil];
            [self generateScabs];
        } else {
            NSLog(@"USING EXISTING BOARD");
            [self displayExistingBoard];
        }
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self scheduleUpdate];
    }
            
    return self;
}

- (void)displayExistingBoard {
    NSLog(@"DISPLAY EXISTING BOARD");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [app.scabs addObjectsFromArray:(NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"scabs"]]];
    [self updateBackground:[defaults stringForKey:@"skinBackgroundNumber"]];
    
    NSLog(@"NUMBER OF SCABS: %d", [app.scabs count]);
    for (Scab *scab in app.scabs) {
        [scab displaySprites];
    }    
}

- (void)generateScabs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGRect backgroundBoundary = [[skinBackgroundBoundaries objectForKey:[defaults stringForKey:@"skinBackgroundNumber"]] CGRectValue];
    
    int numScabs = (arc4random() % NUM_INDIVIDUAL_SCABS) + 1;
    for (int x = 0; x < numScabs; x++) {
        [app.scabs addObject:[[Scab alloc] createWithBackgroundBoundary:backgroundBoundary]];
    }
    
    if ((arc4random() % PERCENT_CHANCE_OF_SPECIAL_SCAB) == 1)
        [app.scabs addObject:[[Scab alloc] createSpecialWithBackgroundBoundary:backgroundBoundary]];
}

- (void)setupSkinBackgroundBoundaries {
    self.skinBackgroundBoundaries = [[NSMutableDictionary alloc] init];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(80, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - 80 -X_SCAB_BORDER_BOUNDARY, 165)] forKey:@"0"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 275)] forKey:@"1"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), app.screenHeight - (Y_SCAB_BORDER_BOUNDARY * 2))] forKey:@"2"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), app.screenHeight - (Y_SCAB_BORDER_BOUNDARY * 2))] forKey:@"3"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 225)] forKey:@"4"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), 205)] forKey:@"5"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(50, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - 100, 235)] forKey:@"6"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(X_SCAB_BORDER_BOUNDARY, Y_SCAB_BORDER_BOUNDARY, app.screenWidth - (X_SCAB_BORDER_BOUNDARY * 2), app.screenHeight - (Y_SCAB_BORDER_BOUNDARY * 2))] forKey:PHOTO_BACKGROUND];
}

- (void)updateBackground:(NSString *)skinBackgroundNumber {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [(CCSprite *)[self getChildByTag:BACKGROUND_IMAGE_TAG_ID] removeFromParentAndCleanup:YES];
    
    if (skinBackgroundNumber == nil)
        skinBackgroundNumber = [NSString stringWithFormat:@"%d", arc4random() % NUM_BACKGROUNDS];
    
    CCSprite *bg;
    if ([[defaults objectForKey:@"skinColor"] isEqualToString:@"photo"]) {
        NSData *imageData = [defaults objectForKey:@"photoBackground"];
        UIImage *image = [UIImage imageWithData:imageData];
        bg = [CCSprite spriteWithCGImage:image.CGImage key:[NSString stringWithFormat:@"%d", (arc4random() % 1000) + 1]];

    } else {
        NSString *skinBackground = [NSString stringWithFormat:@"%@_skin_background%@.jpg", [defaults objectForKey:@"skinColor"], skinBackgroundNumber];
        NSLog(@"SETTING BACKGROUND: %@", skinBackground);
        bg = [CCSprite spriteWithFile:skinBackground];
    }
    
    bg.tag = BACKGROUND_IMAGE_TAG_ID;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    
    [defaults setObject:skinBackgroundNumber forKey:@"skinBackgroundNumber"];
    [defaults synchronize];
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

- (void)reportAchievementsForScab:(Scab *)scab {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![scab.name isEqualToString:@"standard"]) {
        [app.gameCenterBridge reportAchievementIdentifier:[NSString stringWithFormat:@"iscab_%@", scab.name]];
    } else if ([scab.name isEqualToString:@"standard"] && scab.scabSize == SMALL_SCAB) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:@"iscab_pityscab"])
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_pityagain"];
        else
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_pity"];
    }
    
    NSArray *specialScabNames = [SpecialScabs specialScabNames];
    bool allSpecialScabsPicked = true;
    for (int i = 0; i < [specialScabNames count]; i++) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:[specialScabNames objectAtIndex:i]] == nil)
            allSpecialScabsPicked = false;
    }
    
    if (allSpecialScabsPicked)
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_allspecial"];
    
    int jarsFilled = 0;
    for (int i = 0; i < [app.jars count]; i++) {
        if ([[app.jars objectAtIndex:i] numScabLevels] == MAX_NUM_SCAB_LEVELS)
            jarsFilled += 1;
    }
    
    switch (jarsFilled) {
        case 1:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_1filled"];
            break;
        case 2:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_2filled"];
            break;
        case 3:
            [GameCenterBridge reportScore:[[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"startTime"]] forCategory:@"iscab_leaderboard"];
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_3filled"];
            break;
        default:
            break;
    }
}

- (void)addScabToJar:(Scab *)scab {        
    NSLog(@"SCORE: %d", [scab pointValue]);
    Jar *currentJar = [app currentJar];
    currentJar.numScabLevels += [scab pointValue];
    if (currentJar.numScabLevels >= MAX_NUM_SCAB_LEVELS)
        currentJar.numScabLevels = MAX_NUM_SCAB_LEVELS;
    
    [self reportAchievementsForScab:(Scab *)scab];
           
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

- (void)warnAboutOverpicking:(Scab *)scabToWarnFor {
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"OVERPICK WARNING" message:@"Don't over-pick!\nIt'll take longer to heal and longer to fill up you scab jar!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warning show];
    [warning release];
    
    [scabToWarnFor setHealDate:[NSDate dateWithTimeIntervalSinceNow:[scabToWarnFor maximumHealingInterval]]];
    [scabToWarnFor setIsOverpickWarningIssued:YES];
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

#pragma touch_elements

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGRect touchRect = CGRectMake(
        touchLocation.x - (MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL / 2), 
        touchLocation.y - (MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL /2), 
        MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL,
        MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL
    );
        
    NSMutableArray *removedScabs = [NSMutableArray array];
    for (ScabChunk *scabChunk in [self activeScabChunks]) {
        if (CGRectContainsPoint(touchRect, scabChunk.savedLocation)) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];
            
            if ([scabChunk health] > 0)
                scabChunk.health -= 1;
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                int numWarningsIssued = 0;
                for (Scab *scab in app.scabs) {
                    if (scab.isOverpickWarningIssued)
                        numWarningsIssued++;
                }
                
                if ([scabChunk.scab isOverpicked] && ![scabChunk.scab isOverpickWarningIssued] && (numWarningsIssued < MAX_NUMBER_OF_OVERPICK_WARNINGS_PER_SESSION))
                    [self warnAboutOverpicking:scabChunk.scab];
                                
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
        [self removeScabChunk:removedScabChunk initing:NO];
    }
    [removedScabs removeAllObjects];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"TOUCH ENDED");
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
}

#pragma exit/enter setup

- (void)onExit {
    [super onExit];
    NSLog(@"ON EXIT");
    [app saveState];
}

- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    NSLog(@"ON ENTER TRANSITION DID FINISH");
    if (![app.scabs count])
        [self displayExistingBoard];
}

- (void)dealloc {
    [super dealloc];
    /*
    cpSpaceFree(space);
    [skinBackground release];
    [skinBackgroundBoundaries release];
    [batchNode release];
    [allScabs release];
    [allWounds release];
    [allBlood release];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];*/
}

#pragma singletons

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

@end