//
//  GamePlay.m
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlay.h"
#import "Wound.h"
#import "Scab.h"
#import "SimpleAudioEngine.h"
#import "MainMenu.h"
#import "JarScene.h"
#import "AppDelegate.h"
#import "drawSpace.h"
#import "cpSpace.h"
#import "GameCenterBridge.h"
#import "SpecialScab.h"

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
        
        [spritesToDelete release];
        
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
    NSLog(@"ROTATED");
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft))
        space->gravity = ccp(-GRAVITY_FACTOR, 0);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
        space->gravity = ccp(GRAVITY_FACTOR, 0);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait))
        space->gravity = ccp(0, -GRAVITY_FACTOR);
    else if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown))
        space->gravity = ccp(0, -GRAVITY_FACTOR);

    self.gravity = space->gravity;
}

- (id)init {
    if((self = [super init])) {
        NSLog(@"INSIDE GAMEPLAY INIT");
        app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self setIsTouchEnabled:YES];
        endSequenceRunning = false;
        
        [self setupSkinBackgroundBoundaries];
        [self createSpace];
                 
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

    Scab *scab = nil;
    int numScabsPicked = [[app.defaults objectForKey:@"numScabsPicked"] intValue];
    if ((((arc4random() % 10) + 1) <= CHANCE_OF_GETTING_SPECIAL_SCAB) || (numScabsPicked == FIRST_FORCED_SPECIAL_SCAB))
        scab = [[SpecialScab alloc] createWithBackgroundBoundary:backgroundBoundary];
    else
        scab = [[Scab alloc] createWithBackgroundBoundary:backgroundBoundary];
    
    [app setScab:scab];
    [scab release];
                
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
    
    [bg setTag:BACKGROUND_IMAGE_TAG_ID];
    [bg setAnchorPoint:ccp(0, 0)];
    [bg setPosition:ccp(0, 0)];
    [self addChild:bg z:-1];
    
    [app.defaults setObject:skinBackgroundNumber forKey:@"skinBackgroundNumber"];
}

- (void)addScabToJar:(Scab *)scab {
    if ([app.defaults boolForKey:@"tutorial"]) {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Scab Added" message:@"TUTORIAL: You've just added a scab to your jar. You can check out your collection and share it with friends as you fill it up!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warning show];
        [warning release];
    }

    [app.gameCenterBridge reportAchievementsForScab:(Scab *)scab];

    NSLog(@"SCORE: %d", [scab pointValue]);
    Jar *currentJar = [app currentJar];
    currentJar.numScabLevels += [scab pointValue];
    if (currentJar.numScabLevels >= MAX_NUM_SCAB_LEVELS) {
        currentJar.numScabLevels = MAX_NUM_SCAB_LEVELS;
        [app.defaults setObject:[NSDate date] forKey:@"jarStartTime"];
    }
               
    CCSprite *scorePopup = [CCSprite spriteWithFile:@"scab_added.png"];
    [scorePopup setPosition:ccp(195, 40)];
    [scorePopup runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], [CCHide action], nil]];        
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
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCCallFunc actionWithTarget:self selector:@selector(resetBoard)], nil]];        
    } else if ([app.scab isDevoidOfScabsAndNotFullyHealed] && [app.defaults boolForKey:@"tutorial"]) {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Scab Needs Healing" message:@"TUTORIAL: You have to wait for it to heal and you'll get an itchy notification." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warning show];
        [warning release];
    }
}

- (void)resetBoard {
    [app cleanupBatchNode];
    [app.scab reset];
    
    [looseScabChunks removeAllObjects];
    
    for (CCMotionStreak *streak in [self allBlood])
        [streak removeFromParentAndCleanup:NO];

    allBlood = nil;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self updateBackground:nil];
    [self generateScab];
    endSequenceRunning = false;
    NSLog(@"LEAVING RESET BOARD");
}

- (void)warnAboutOverpicking:(Scab *)scab {
    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"OVERPICK WARNING" message:@"TUTORIAL: Don't over-pick!\nIt'll take longer to heal and longer to fill up you scab jar!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [warning show];
    [warning release];
    
    [scab setHealDate:[NSDate dateWithTimeIntervalSinceNow:[scab maximumHealingInterval]]];
    [scab setIsOverpickWarningIssued:YES];
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
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"Scratch%d.m4a", arc4random() % NUM_SCRATCH_SOUNDS] pitch:1.0 pan:1.0 gain:0.25];
            
            if ([scabChunk health] > 0)
                scabChunk.health -= 1;
            
            if (([scabChunk health] <= 0)) {
                [removedScabs addObject:scabChunk];
                [scabChunk ripOffScab];
                
                if (
                    [scabChunk.scab isOverpicked] && 
                    ![scabChunk.scab isOverpickWarningIssued] && 
                    [app.defaults boolForKey:@"tutorial"] &&
                    ![scabChunk.scab isHealed]
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
    
    [removedScabs release];
}

- (void)onEnter {
    NSLog(@"GAMEPLAY ONENTER");
    [super onEnter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self addChild:app.batchNode];
    
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
    NSLog(@"GAMEPLAY ON EXIT");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [app scheduleNotifications];
    [app cleanupBatchNode];
    [app saveState];
    [app.scab reset];

    [self removeChild:app.batchNode cleanup:YES];
    
    [super onExit];
}

- (void)dealloc {
    [allBlood release];
    [looseScabChunks release];
    [skinBackgroundBoundaries release];
    [super dealloc];
}

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