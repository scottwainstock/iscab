//
//  Scab.h
//  iscab
//
//  Created by Scott Wainstock on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_SPECIAL_SCAB_EXTRA_SCAB_CHUNKS 30
#define SPECIAL_SCAB_WIDTH_FOR_EXTRA_SCAB_CHUNKS 100
#define SPECIAL_SCAB_HEIGHT_FOR_EXTRA_SCAB_CHUNKS 100

#define NUM_SHAPE_TYPES 4
#define NUM_DARK_PATCHES 4
#define OVERPICKED_THRESHOLD 0.5

#define SCABS_LEFT_TO_BE_CONSIDERED_COMPLETE 5

#define MINIMUM_SCAB_SIZE 100

#define MEDIUM_SCAB_SIZE 200
#define LARGE_SCAB_SIZE 300
#define XL_SCAB_SIZE 301

#define MIN_SCAB_WIDTH 100
#define MIN_SCAB_HEIGHT 100
#define EXTRA_SCAB_WIDTH 250
#define EXTRA_SCAB_HEIGHT 250

#define SMALL_HEALING_TIME 60 * 2
#define MEDIUM_HEALING_TIME 120 * 2
#define LARGE_HEALING_TIME 180 * 2
#define XL_HEALING_TIME 240 * 2
 
#define SMALL_SCAB 0
#define MEDIUM_SCAB 1
#define LARGE_SCAB 2
#define XL_SCAB 3

@interface Scab : NSObject <NSCoding> {
    int sizeAtCreation;
    bool isOverpickWarningIssued;
    CGPoint center;
    NSMutableArray *scabChunks;
    NSMutableArray *wounds;
    NSMutableArray *scabChunkBorders;
    NSDate *birthday;
    NSDate *healDate;
    NSString *name;
}

@property (nonatomic, assign) bool isOverpickWarningIssued;
@property (nonatomic, assign) int sizeAtCreation;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSDate *healDate;
@property (nonatomic, retain) NSMutableArray *wounds;
@property (nonatomic, retain) NSMutableArray *scabChunks;
@property (nonatomic, retain) NSMutableArray *scabChunkBorders;

- (bool)isHealed;
- (bool)isOverpicked;
- (bool)isDevoidOfScabsAndNotFullyHealed;
- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary;
- (id)createScabChunk:(CGPoint)coordinates type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority;
- (int)pointValue;
- (int)scabSize;
- (void)reset;
- (void)displaySprites;
- (void)createScabChunkAndBorderWithCenter:(CGPoint)scabChunkCenter type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority;
- (void)createWoundFromIScabSprite:(id)iscabSprite isClean:(bool)isClean;
- (void)initializeStatesWithName:(NSString *)scabName;
- (NSMutableArray *)randomScabChunksForOrigin:(CGPoint)scabOrigin withBoundary:(CGRect)boundary;
- (NSTimeInterval)maximumHealingInterval;
- (NSTimeInterval)healingInterval;
- (CGPoint)generateScabOrigin:(CGRect)backgroundBoundary;
- (CGPoint)getScabChunkCenterFrom:(CGPoint)scabCenter backgroundBoundary:(CGRect)backgroundBoundary scabOrigin:(CGPoint)scabOrigin;

@end