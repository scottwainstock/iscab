//
//  Scab.h
//  iscab
//
//  Created by Scott Wainstock on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_SPECIAL_SCAB_EXTRA_SCAB_CHUNKS 30
#define SPECIAL_SCAB_WIDTH_FOR_EXTRA_SCAB_CHUNKS 75
#define SPECIAL_SCAB_HEIGHT_FOR_EXTRA_SCAB_CHUNKS 40

#define XXX_SCAB_SIZE 30

#define NUM_SHAPE_TYPES 4
#define NUM_DARK_PATCHES 4
#define OVERPICKED_THRESHOLD 0.5

#define MEDIUM_SCAB_SIZE 200
#define LARGE_SCAB_SIZE 300
#define XL_SCAB_SIZE 301

#define MAX_SCAB_WIDTH 100
#define MAX_SCAB_HEIGHT 100

/*
#define SMALL_HEALING_TIME 1
#define MEDIUM_HEALING_TIME 7200
#define LARGE_HEALING_TIME 18000
#define XL_HEALING_TIME 28800
*/

#define SMALL_HEALING_TIME 60
#define MEDIUM_HEALING_TIME 120
#define LARGE_HEALING_TIME 180
#define XL_HEALING_TIME 240

#define SMALL_SCAB 0
#define MEDIUM_SCAB 1
#define LARGE_SCAB 2
#define XL_SCAB 3

@interface Scab : NSObject <NSCoding> {
    CGPoint center;
    NSMutableArray *scabChunks;
    NSMutableArray *wounds;
    NSMutableArray *scabChunkBorders;
    NSDate *birthday;
    NSDate *healDate;
    int sizeAtCreation;
    bool isAged;
    bool isOverpickWarningIssued;
}

@property (nonatomic, assign) bool isOverpickWarningIssued;
@property (nonatomic, assign) bool isAged;
@property (nonatomic, assign) int sizeAtCreation;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSDate *healDate;
@property (nonatomic, retain) NSMutableArray *wounds;
@property (nonatomic, retain) NSMutableArray *scabChunks;
@property (nonatomic, retain) NSMutableArray *scabChunkBorders;

- (bool)isOverpicked;
- (bool)isComplete;
- (id)createSpecialWithBackgroundBoundary:(CGRect)backgroundBoundary;
- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary;
- (id)createScabChunk:(CGPoint)coordinates type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority;
- (int)pointValue;
- (int)scabSize;
- (void)reset;
- (void)displaySprites;
- (void)createScabChunkAndBorderWithCenter:(CGPoint)scabChunkCenter type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority;
- (void)createWoundFromIScabSprite:(id)iscabSprite isClean:(bool)isClean;
- (NSMutableArray *)randomScabChunksForOrigin:(CGPoint)scabOrigin withBoundary:(CGRect)backgroundBoundary;
- (NSTimeInterval)maximumHealingInterval;
- (NSTimeInterval)healingInterval;
- (CGPoint)generateScabOrigin:(CGRect)backgroundBoundary;
- (CGPoint)getScabChunkCenterFrom:(CGPoint)scabCenter backgroundBoundary:(CGRect)backgroundBoundary scabBoundary:(CGRect)scabBoundary maxDistanceToXEdge:(int)maxDistanceToXEdge maxDistanceToYEdge:(int)maxDistanceToYEdge;

@end