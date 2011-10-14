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

@interface GamePlay : IScabCCLayer {
    cpMouse *mouse;    
    cpSpace *space;
    CCSpriteBatchNode *batchNode;
    NSMutableArray *allScabs;
    NSMutableArray *allWounds;
    NSMutableArray *allBlood;
    NSMutableArray *looseScabs;
    cpVect gravity;
    CGPoint centerOfScab;
    NSString *skinBackground;
    NSMutableDictionary *skinBackgroundOffsets;
    int sizeOfMoveableScab;
    IScabSprite *moveableScab;
}

@property (nonatomic) int sizeOfMoveableScab;
@property (nonatomic) CGPoint centerOfScab;
@property (nonatomic, assign) IScabSprite *moveableScab;
@property (nonatomic, assign) cpVect gravity;
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) NSMutableArray *allScabs;
@property (nonatomic, retain) NSMutableArray *allWounds;
@property (nonatomic, retain) NSMutableArray *allBlood;
@property (nonatomic, retain) NSMutableArray *looseScabs;
@property (nonatomic, retain) NSString *skinBackground;
@property (nonatomic, retain) NSMutableDictionary *skinBackgroundOffsets;

+ (id)scene;
+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding scabNo:(int)scabNo;

- (void)addScabChunk:(ScabChunk *)scabChunk fromLocation:(CGPoint)location;
- (CGPoint)getCenterOfScab;
- (void)setupSkinBackgroundOffsets;
- (void)removeScab:(ScabChunk *)chunk;
- (void)generateScabs;
- (void)clearLowerScabs:(ScabChunk *)newScab;
- (void)createWound:(ScabChunk *)scab cleanSkin:(bool)clean;
- (ScabChunk *)createScab:(CGPoint)coordinates type:(NSString *)type scabIndex:(int)scabIndex havingPriority:(int)priority;
- (void)removeScab:(ScabChunk *)scab initing:(bool)initing;
- (void)displaySavedBoard;
- (void)updateBackground:(NSString *)skinBackground;
- (cpSpace *)createSpace;

@end
