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

@interface GamePlay : CCLayer {
    cpMouse *mouse;    
    cpSpace *space;
    CCSpriteBatchNode *batchNode;
    NSMutableArray *allScabs;
    NSMutableArray *allWounds;
    NSMutableArray *allBlood;
    cpVect gravity;
}

@property (nonatomic, assign) cpVect gravity;
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, retain) NSMutableArray *allScabs;
@property (nonatomic, retain) NSMutableArray *allWounds;
@property (nonatomic, retain) NSMutableArray *allBlood;

+ (id)scene;
+ (NSString *)woundFrameNameForClean:(bool)isClean isBleeding:(bool)isBleeding;

- (void)removeScab:(ScabChunk *)chunk;
- (void)generateScabs;
- (void)clearLowerScabs:(ScabChunk *)newScab;
- (void)createWound:(ScabChunk *)scab cleanSkin:(bool)clean;
- (ScabChunk *)createScab:(CGPoint)coordinates usingScabIndex:(int)scabIndex havingPriority:(int)priority;
- (void)removeScab:(ScabChunk *)scab initing:(bool)initing;
- (void)displaySavedBoard;
- (void)updateBackground;
- (cpSpace *)createSpace;

@end
