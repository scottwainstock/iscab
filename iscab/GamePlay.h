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
#import "cpShape.h"

#define NUM_BACKGROUNDS 6
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL 20.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS 10
#define NUM_INDIVIDUAL_SCABS 6
#define BACKGROUND_IMAGE_TAG_ID 777
#define X_SCAB_BORDER_BOUNDARY 10
#define Y_SCAB_BORDER_BOUNDARY 10

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
- (bool)isBoardCompleted;
- (void)setupSkinBackgroundBoundaries;
- (void)generateScabs;
- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing;
- (void)updateBackground:(NSString *)skinBackground;
- (NSMutableArray *)activeScabChunks;
- (cpSpace *)createSpace;

@end
