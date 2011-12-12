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
#import "GameCenterBridge.h"
#import "SpecialScabs.h"

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
        }
        
        //[spritesToDelete release];
        
        for (CCMotionStreak *streak in self.allBlood) {
            if (arc4random() % 2 == 1) {
                CGPoint position = streak.position;
                
                if (self.gravity.x > 0)
                    position.x = position.x + 1;
                else if (self.gravity.x < 0)
                    position.x = position.x - 1;
                else if (self.gravity.y > 0)
                    position.y = position.y + 1;
                else if (self.gravity.y < 0)
                    position.y = position.y - 1;
                
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
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft))
        space->gravity = ccp(-GRAVITY_FACTOR, 0);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
        space->gravity = ccp(GRAVITY_FACTOR, 0);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait))
        space->gravity = ccp(0, -GRAVITY_FACTOR);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown))
        space->gravity = ccp(0, GRAVITY_FACTOR);

    self.gravity = space->gravity;
}

- (id)init {
    if((self = [super init])) {
        NSLog(@"INSIDE GAMEPLAY INIT");
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.isTouchEnabled = YES;
        endSequenceRunning = false;
        NSLog(@"GAMEPLAY SETUP COMPLETE");
        
        [self setupSkinBackgroundBoundaries];
        NSLog(@"SETUP SKINBACKGROUND");
        [self createSpace];
        NSLog(@"CREATED SPACE");
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
                    
        [self addChild:app.batchNode];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self scheduleUpdate];
        
        NSLog(@"DONE INITING");
    }
            
    return self;
}

- (void)displayExistingBoard {
    NSLog(@"DISPLAY EXISTING BOARD");

    [app setScab:(Scab *)[NSKeyedUnarchiver unarchiveObjectWithData:[app.defaults objectForKey:@"scab"]]];
    [self updateBackground:[app.defaults stringForKey:@"skinBackgroundNumber"]];
    
    [app.scab displaySprites];
}

- (void)generateScab {
    CGRect backgroundBoundary = [[skinBackgroundBoundaries objectForKey:[app.defaults stringForKey:@"skinBackgroundNumber"]] CGRectValue];

    int numScabsPicked = [[app.defaults objectForKey:@"numScabsPicked"] intValue];
    if ((((arc4random() % 10) + 1) <= CHANCE_OF_GETTING_SPECIAL_SCAB) || (numScabsPicked == FIRST_FORCED_SPECIAL_SCAB))
        [app setScab:[[Scab alloc] createSpecialWithBackgroundBoundary:backgroundBoundary]];
    else
        [app setScab:[[Scab alloc] createWithBackgroundBoundary:backgroundBoundary]];
    
    NSLog(@"DONE GENERATING SCAB");
}

- (void)setupSkinBackgroundBoundaries {
    self.skinBackgroundBoundaries = [[NSMutableDictionary alloc] init];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(85, 20, 160, 140)] forKey:@"0"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 85, 270, 170)] forKey:@"1"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 95, 275, 360)] forKey:@"2"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 90, 275, 360)] forKey:@"3"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 85, 270, 165)] forKey:@"4"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 85, 270, 120)] forKey:@"5"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(80, 20, 160, 210)] forKey:@"6"];
    [self.skinBackgroundBoundaries setObject:[NSValue valueWithCGRect:CGRectMake(25, 90, 275, 360)] forKey:PHOTO_BACKGROUND];
}

- (void)updateBackground:(NSString *)skinBackgroundNumber {
    [(CCSprite *)[self getChildByTag:BACKGROUND_IMAGE_TAG_ID] removeFromParentAndCleanup:YES];
    
    if (skinBackgroundNumber == nil)
        skinBackgroundNumber = [NSString stringWithFormat:@"%d", arc4random() % NUM_BACKGROUNDS];

    CCSprite *bg;
    if ([[app.defaults objectForKey:@"skinColor"] isEqualToString:@"photo"]) {
        NSData *imageData = [app.defaults objectForKey:@"photoBackground"];
        UIImage *image = [UIImage imageWithData:imageData];
        bg = [CCSprite spriteWithCGImage:image.CGImage key:[NSString stringWithFormat:@"%d", (arc4random() % 1000) + 1]];
    } else {
        NSString *skinBackground = [NSString stringWithFormat:@"%@_skin_background%@.jpg", [app.defaults objectForKey:@"skinColor"], skinBackgroundNumber];
        NSLog(@"SETTING BACKGROUND: %@", skinBackground);
        bg = [CCSprite spriteWithFile:skinBackground];
    }
    
    bg.tag = BACKGROUND_IMAGE_TAG_ID;
    bg.anchorPoint = ccp(0, 0);
    bg.position = ccp(0, 0);
    [self addChild:bg z:-1];
    
    [app.defaults setObject:skinBackgroundNumber forKey:@"skinBackgroundNumber"];
}

- (void)reportAchievementsForScab:(Scab *)scab {
    if (!scab.isOverpickWarningIssued)
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_surgeon"];
    
    if (![scab.name isEqualToString:@"standard"])
        [app.gameCenterBridge reportAchievementIdentifier:[NSString stringWithFormat:@"iscab_%@", scab.name]];
    
    if ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= SCAB_GOOD_TIME)
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_goodtime"];
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_GOOD_TIME)
    ) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:@"iscab_biggood"])
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_biggoodagain"];
        else
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_biggood"];
    }
   
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_MIN_TIME)
    ) {
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_bigmin"];
        
        int numBigScabsPickedInMinimumTime = [[app.defaults objectForKey:@"iscab_3big"] intValue];
        numBigScabsPickedInMinimumTime += 1;
        
        if (numBigScabsPickedInMinimumTime >= 3)
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_3big"];
            
        [app.defaults setObject:[NSNumber numberWithInt:numBigScabsPickedInMinimumTime] forKey:@"iscab_3big"];
    }
    
    if (
        [scab.name isEqualToString:@"standard"] && 
        (scab.scabSize == XL_SCAB) &&
        ([[NSDate date] timeIntervalSinceDate:scab.birthday] <= BIG_SCAB_QUICKLY)
    )
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_bigquick"];
    
    if ([scab.name isEqualToString:@"standard"] && scab.scabSize == SMALL_SCAB) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:@"iscab_pityscab"])
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_pityagain"];
        else
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_pity"];
    }
    
    bool allSpecialScabsPicked = true;
    for (NSString *specialScabName in [SpecialScabs specialScabNames]) {
        if ([app.gameCenterBridge.achievementsDictionary objectForKey:specialScabName] == nil)
            allSpecialScabsPicked = false;
    }
    
    if (allSpecialScabsPicked)
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_allspecial"];
    
    int jarsFilled = 0;
    for (Jar *jar in app.jars)
        if ([jar numScabLevels] == MAX_NUM_SCAB_LEVELS)
            jarsFilled += 1;
    
    switch (jarsFilled) {
        case 1:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_1filled"];
            break;
        case 2:
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_2filled"];
            break;
        case 3:
            [GameCenterBridge reportScore:[[NSDate date] timeIntervalSinceDate:[app.defaults objectForKey:@"gameStartTime"]] forCategory:@"iscab_leaderboard"];
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
    if (currentJar.numScabLevels >= MAX_NUM_SCAB_LEVELS) {
        currentJar.numScabLevels = MAX_NUM_SCAB_LEVELS;
        
        if ([[NSDate date] timeIntervalSinceDate:[app.defaults objectForKey:@"jarStartTime"]] <= SPEEDILY_FILLED_JAR_TIME)
            [app.gameCenterBridge reportAchievementIdentifier:@"iscab_speedjar"];
        
        [app.defaults setObject:[NSDate date] forKey:@"jarStartTime"];
    }
    
    [self reportAchievementsForScab:(Scab *)scab];
           
    CCSprite *scorePopup = [CCSprite spriteWithFile:@"scab_added.png"];
    [scorePopup setPosition:ccp(195, 40)];
    [scorePopup runAction:[CCFadeOut actionWithDuration:4]]; 
    [self addChild:scorePopup z:100];
}

- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing {
    [scabChunk destroy];

    if ([app.scab isComplete]) {
        [self addScabToJar:app.scab];
        
        int numScabsPicked = [[app.defaults objectForKey:@"numScabsPicked"] intValue];
        numScabsPicked += 1;
        [app.defaults setObject:(NSNumber *)[NSNumber numberWithInt:numScabsPicked] forKey:@"numScabsPicked"];
        
        endSequenceRunning = true;
        [[SimpleAudioEngine sharedEngine] playEffect:@"scabcomplete.wav"];
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];
        
        [app.gameCenterBridge reportAchievementIdentifier:@"iscab_power"];
    }
}

- (void)resetBoard {
    [app.scab reset];
    
    for (CCMotionStreak *streak in [self allBlood])
        [streak removeFromParentAndCleanup:NO];

    allBlood = nil;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self updateBackground:nil];
    [self generateScab];
    endSequenceRunning = false;
    NSLog(@"LEAVING RESET BOARD");
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
        
    NSMutableArray *removedScabs = [[NSMutableArray alloc] init];
    for (ScabChunk *scabChunk in [app.scab scabChunks]) {
        if (CGRectContainsPoint(touchRect, scabChunk.savedLocation)) {
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS]];
            
            if ([scabChunk health] > 0)
                scabChunk.health -= 1;
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                if (
                    [scabChunk.scab isOverpicked] && 
                    ![scabChunk.scab isOverpickWarningIssued] &&
                    ([[app.defaults objectForKey:@"numScabsPicked"] intValue] <= MAX_NUMBER_OF_OVERPICK_WARNINGS)
                )
                    [self warnAboutOverpicking:scabChunk.scab];
                                
                if ([looseScabChunks count] < MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS) {
                    IScabSprite *looseScab = [[IScabSprite alloc] initWithSpace:space location:scabChunk.position filename:[scabChunk filename] shapeNo:scabChunk.scabChunkNo];
                    
                    [self.looseScabChunks addObject:looseScab];
                    [app.batchNode addChild:looseScab];
                }            
            }
        }
    }
    
    for (ScabChunk *removedScabChunk in removedScabs)
        [self removeScabChunk:removedScabChunk initing:NO];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"TOUCH ENDED");
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ccTouchEnded:touch withEvent:event]; 
}

#pragma exit/enter setup

- (void)onEnter {
    [super onEnter];
    
    if (![app.defaults objectForKey:@"scab"]) {
        NSLog(@"GENERATING NEW BOARD");
        [self updateBackground:nil];
        [self generateScab];
    } else {
        NSLog(@"USING EXISTING BOARD");
        [self displayExistingBoard];
    }
}

- (void)onExit {
    [super onExit];
    NSLog(@"ON EXIT");
    [app saveState];
}

- (void)dealloc {
    [allBlood release];
    [looseScabChunks release];
    [skinBackgroundBoundaries release];
    [super dealloc];
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

@end