//
//  GamePlay.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IScabCCLayer.h"
#import "IScabSprite.h"
#import "ScabChunk.h"
#import "cocos2d.h"
#import "chipmunk.h"

#define NUM_BACKGROUNDS 6
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL 20.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS 10
#define BACKGROUND_IMAGE_TAG_ID 777
#define X_SCAB_BORDER_BOUNDARY 10
#define Y_SCAB_BORDER_BOUNDARY 10
#define PHOTO_BACKGROUND @"50"
#define MAX_NUMBER_OF_OVERPICK_WARNINGS_PER_SESSION 2
#define FIRST_FORCED_SPECIAL_SCAB 2
#define CHANCE_OF_GETTING_SPECIAL_SCAB 2

@interface GamePlay : IScabCCLayer {
    cpSpace *space;
    cpVect gravity;
    bool endSequenceRunning;
    NSMutableArray *allBlood;
    NSMutableArray *looseScabChunks;
    NSMutableDictionary *skinBackgroundBoundaries;
}

@property (nonatomic) bool endSequenceRunning;
@property (nonatomic, assign) cpVect gravity;
@property (nonatomic, retain) NSMutableArray *allBlood;
@property (nonatomic, retain) NSMutableArray *looseScabChunks;
@property (nonatomic, retain) NSMutableDictionary *skinBackgroundBoundaries;

+ (id)scene;

- (void)displayExistingBoard;
- (void)warnAboutOverpicking:(Scab *)scabToWarnFor;
- (void)setupSkinBackgroundBoundaries;
- (void)generateScab;
- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing;
- (void)updateBackground:(NSString *)skinBackground;
- (cpSpace *)createSpace;

@end
