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
    cpSpace *space;
    cpMouse *mouse;    
    CCSpriteBatchNode *batchNode;
}

@property (nonatomic, assign) CCSpriteBatchNode *batchNode;

+ (id)scene;
- (void)removeScab:(ScabChunk *)chunk;
- (void)generateScabs;
- (void)clearLowerScabs:(ScabChunk *)newScab;
- (void)createWound:(ScabChunk *)scab;
- (ScabChunk *)createScab:(CGPoint)coordinates usingScabIndex:(int)scabIndex havingPriority:(int)priority;
- (void)displayBoard;
- (void)updateBackground;

@end
