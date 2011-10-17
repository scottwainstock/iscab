//
//  GamePlay.h
//  iscab
//
//  Created by Scott Wainstock on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ScabChunk.h"
#import "IScabCCLayer.h"
#import "chipmunk.h"
#import "cpMouse.h"
#import "cpShape.h"

#define NUM_SHAPE_TYPES 4
#define NUM_BACKGROUNDS 8
#define NUM_SCRATCH_SOUNDS 3
#define MINIMUM_DISTANCE_FOR_CLOSE_SCAB_CHUNK_REMOVAL 10.0
#define GRAVITY_FACTOR 750
#define MAXIMUM_NUMBER_OF_LOOSE_SCAB_CHUNKS 10
#define NUM_INDIVIDUAL_SCABS 6
#define NUM_DARK_PATCHES 4

@interface GamePlay : IScabCCLayer {
    cpMouse *mouse;    
    cpSpace *space;
    CCSpriteBatchNode *batchNode;
    NSMutableArray *allScabChunks;
    NSMutableArray *allWounds;
    NSMutableArray *allBlood;
    NSMutableArray *looseScabChunks;
    cpVect gravity;
    CGPoint centerOfAllScabs;
    NSString *skinBackground;
    NSMutableDictionary *skinBackgroundOffsets;
    int sizeOfMoveableScab;
    IScabSprite *moveableScab;
    int screenWidth;
    int screenHeight;
}

@property (nonatomic) int sizeOfMoveableScab;
@property (nonatomic) CGPoint centerOfAllScabs;
@property (nonatomic, assign) IScabSprite *moveableScab;
@property (nonatomic, assign) cpVect gravity;
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) NSMutableArray *allScabChunks;
@property (nonatomic, retain) NSMutableArray *allWounds;
@property (nonatomic, retain) NSMutableArray *allBlood;
@property (nonatomic, retain) NSMutableArray *looseScabChunks;
@property (nonatomic, retain) NSString *skinBackground;
@property (nonatomic, retain) NSMutableDictionary *skinBackgroundOffsets;

+ (id)scene;
+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding scabNo:(int)scabNo;

- (void)initializeSprites;
- (CGPoint)getScabChunkCenterFrom:(CGPoint)origin scabBoundingRect:(CGRect)scabBoundingRect maxDistanceToXEdge:(int)maxDistanceToXEdge maxDistanceToYEdge:(int)maxDistanceToYEdge;
- (void)addScabChunk:(ScabChunk *)scabChunk fromLocation:(CGPoint)location;
- (CGPoint)getCenterOfAllScabs;
- (void)setupSkinBackgroundOffsets;
- (void)generateScabs;
- (void)createWound:(ScabChunk *)scab cleanSkin:(bool)clean;
- (void)createScabChunk:(CGPoint)coordinates type:(NSString *)type scabIndex:(int)scabIndex havingPriority:(int)priority;
- (void)removeScabChunk:(ScabChunk *)scabChunk initing:(bool)initing;
- (void)displaySavedBoard;
- (void)updateBackground:(NSString *)skinBackground;
- (cpSpace *)createSpace;

@end
