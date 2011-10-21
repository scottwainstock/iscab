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
#import "cpMouse.h"
#import "cpShape.h"

#define NUM_BACKGROUNDS 8
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL 20.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS 10
#define NUM_INDIVIDUAL_SCABS 6

@interface GamePlay : IScabCCLayer {
    cpMouse *mouse;    
    cpSpace *space;
    cpVect gravity;
    int sizeOfMoveableScab;
    bool endSequenceRunning;
    IScabSprite *moveableScab;
    CGPoint centerOfAllScabs;
    NSMutableArray *allBlood;
    NSMutableArray *looseScabChunks;
    NSMutableDictionary *skinBackgroundOffsets;
}

@property (nonatomic) bool endSequenceRunning;
@property (nonatomic) int sizeOfMoveableScab;
@property (nonatomic) CGPoint centerOfAllScabs;
@property (nonatomic, assign) IScabSprite *moveableScab;
@property (nonatomic, assign) cpVect gravity;
@property (nonatomic, retain) NSMutableArray *allBlood;
@property (nonatomic, retain) NSMutableArray *looseScabChunks;
@property (nonatomic, retain) NSMutableDictionary *skinBackgroundOffsets;

+ (id)scene;

- (void)addScabChunk:(ScabChunk *)scabChunk fromLocation:(CGPoint)location;
- (CGPoint)getCenterOfAllScabs;
- (void)setupSkinBackgroundOffsets;
- (void)generateScabs;
- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing;
- (void)updateBackground:(NSString *)skinBackground;
- (NSMutableArray *)activeScabChunks;
- (cpSpace *)createSpace;

@end
