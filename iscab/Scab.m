//
//  Scab.m
//  iscab
//
//  Created by Scott Wainstock on 10/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Scab.h"
#import "Wound.h"
#import "GamePlay.h"
#import "AppDelegate.h"

@implementation Scab

@synthesize scabChunks, wounds, center, scabChunkBorders;

- (NSMutableArray *)scabChunks { 
    @synchronized(scabChunks) {
        if (scabChunks == nil)
            scabChunks = [[NSMutableArray alloc] init];
        return scabChunks;
    }
    return nil;
}

- (NSMutableArray *)scabChunkBorders { 
    @synchronized(scabChunkBorders) {
        if (scabChunkBorders == nil)
            scabChunkBorders = [[NSMutableArray alloc] init];
        return scabChunkBorders;
    }
    return nil;
}

- (NSMutableArray *)wounds { 
    @synchronized(wounds) {
        if (wounds == nil)
            wounds = [[NSMutableArray alloc] init];
        return wounds;
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.scabChunks forKey:@"scabChunks"];
    [coder encodeObject:self.scabChunkBorders forKey:@"scabChunkBorders"];
    [coder encodeObject:self.wounds forKey:@"wounds"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Scab alloc] init];
    
    if (self != nil) {
        self.scabChunks = (NSMutableArray *)[coder decodeObjectForKey:@"scabChunks"];
        self.scabChunkBorders = (NSMutableArray *)[coder decodeObjectForKey:@"scabChunkBorders"];
        self.wounds = (NSMutableArray *)[coder decodeObjectForKey:@"wounds"];
    }
    
    NSLog(@"LOADED NUMBER OF SCAB CHUNKS: %d", [self.scabChunks count]);
    NSLog(@"LOADED NUMBER OF SCAB BORDERS: %d", [self.scabChunkBorders count]);
    NSLog(@"LOADED NUMBER OF SCAB WOUNDS: %d", [self.wounds count]);

    return self; 
}

- (int)pointValue {
    if ([self.wounds count] >= XL_SCAB_SIZE) {
        return 4;
    } else if ([self.wounds count] >= LARGE_SCAB_SIZE) {
        return 3;
    } else if ([self.wounds count] >= MEDIUM_SCAB_SIZE) {
        return 2;
    } else {
        return 1;
    }
}

- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary {   
    if ((self = [super init])) {
        int scabXOffset = (arc4random() % (int)backgroundBoundary.size.width) + backgroundBoundary.origin.x;
        int scabYOffset = (arc4random() % (int)backgroundBoundary.size.height) + backgroundBoundary.origin.y;

        CGPoint scabOrigin = CGPointMake(scabXOffset, scabYOffset);
        CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, (arc4random() % MAX_SCAB_WIDTH) + 1, (arc4random() % MAX_SCAB_HEIGHT) + 1);
        
        center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
        
        int maxDistanceToXEdge = (center.x - scabOrigin.x) + 1;
        int maxDistanceToYEdge = (center.y - scabOrigin.y) + 1;
         
        NSLog(@"SCAB ORIGIN: %@", NSStringFromCGPoint(scabOrigin));
        NSLog(@"CENTER OF SCAB: %@", NSStringFromCGPoint(center));
         
        int numScabChunks = (scabBoundary.size.height + scabBoundary.size.width) * 2;         
        for (int x = 0; x < numScabChunks; x++) { 
            int scabChunkNo = arc4random() % NUM_SHAPE_TYPES;
            CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary maxDistanceToXEdge:maxDistanceToXEdge maxDistanceToYEdge:maxDistanceToYEdge];
         
            if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero)) {
                [self createScabChunkAndBorderWithCenter:scabChunkCenter type:@"light" scabChunkNo:scabChunkNo priority:1];
            }
        }
         
        int numDarkPatches = (arc4random() % NUM_DARK_PATCHES);
        for (int x = 0; x < numDarkPatches; x++) {
            CGPoint patchOrigin = CGPointMake(
                (int)center.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
                (int)center.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
            );
         
            for (int x = 0; x < (numScabChunks / 4); x++) {
                int scabChunkNo = arc4random() % NUM_SHAPE_TYPES;
                CGPoint scabChunkCenter = [self getScabChunkCenterFrom:patchOrigin backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary maxDistanceToXEdge:maxDistanceToXEdge maxDistanceToYEdge:maxDistanceToYEdge];
             
                if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero)) {
                    [self createScabChunkAndBorderWithCenter:scabChunkCenter type:@"dark" scabChunkNo:scabChunkNo priority:2];
                }
            }
        }
        NSLog(@"NUM SCAB CHUNKS IN THIS SCAB: %d", [self.scabChunks count]);
    }
    
    return self;
}
    
- (CGPoint)getScabChunkCenterFrom:(CGPoint)scabCenter backgroundBoundary:(CGRect)backgroundBoundary scabBoundary:(CGRect)scabBoundary maxDistanceToXEdge:(int)maxDistanceToXEdge maxDistanceToYEdge:(int)maxDistanceToYEdge {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    CGPoint scabChunkCenter = CGPointMake(
        (int)scabCenter.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
        (int)scabCenter.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
    );
    
    if (
        CGRectContainsPoint(backgroundBoundary, scabChunkCenter)          && // is inside background boundaries
        CGRectContainsPoint(scabBoundary, scabChunkCenter)                && // is inside scab boundaries
        !CGRectContainsPoint(app.homeButton.boundingBox, scabChunkCenter) && // is not inside the home icon
        !CGRectContainsPoint(app.jarButton.boundingBox, scabChunkCenter)     // is not inside the jar icon
    ) {
        return scabChunkCenter;
    }
     
    return CGPointZero;
}
    
- (id)createScabChunk:(CGPoint)coordinates type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    ScabChunk *scabChunk = [[ScabChunk alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"%@_scab%d.png", type, scabChunkNo]];
    [scabChunk setPosition:ccp(coordinates.x, coordinates.y)];
    [scabChunk setSavedLocation:scabChunk.position];
    [scabChunk setScabChunkNo:scabChunkNo];
    [scabChunk setPriority:priority];
    [scabChunk setType:type];
    [scabChunk setHealth:priority * 2];
    [scabChunk setScale:0.8];
    [scabChunk setScab:self];
    [app.batchNode addChild:scabChunk z:5];
    [self.scabChunks addObject:scabChunk];
    //[scabChunk release];
    
    return scabChunk;
}

- (void)createScabChunkBorderFromIScabSprite:(IScabSprite *)iscabSprite {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Wound *scabBorder = [[Wound alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"scab_border%d.png", iscabSprite.scabChunkNo]];
    [scabBorder setPosition:iscabSprite.savedLocation];
    [app.batchNode addChild:scabBorder z:-2];
    [self.scabChunkBorders addObject:scabBorder];
}

- (void)createWoundFromIScabSprite:(IScabSprite *)iscabSprite isClean:(bool)isClean {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
   // [self splatterBlood:scab];
    
    bool isBleeding = (!isClean && (arc4random() % (int)ceil(ccpDistance([app centerOfAllScabs], iscabSprite.savedLocation) * 0.10) == 1)) ? TRUE : FALSE;
    NSString *woundType = [Wound woundFrameNameForClean:isClean isBleeding:isBleeding scabChunkNo:iscabSprite.scabChunkNo];
    
    Wound *wound = [[Wound alloc] initWithSpriteFrameName:woundType];
    [wound setPosition:iscabSprite.savedLocation];
    [wound setSavedLocation:iscabSprite.savedLocation];
    [wound setScabChunkNo:iscabSprite.scabChunkNo];
    [wound setIsClean:isClean];
    [wound setIsBleeding:isBleeding];
    [wound setScale:0.8];
    
    if (wound.isBleeding) {
        for (Wound *savedWound in self.wounds) {
            if (savedWound.isBleeding && (ccpDistance(savedWound.savedLocation, wound.savedLocation) < 5.0) && (arc4random() % 100 == 1)) {
                CCMotionStreak *streak = [[CCMotionStreak streakWithFade:10000.0f minSeg:1 image:@"blood_streak.png" width:10 length:10 color:ccc4(255,255,255,255)] autorelease];
                
                streak.position = wound.savedLocation;
                [(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] addChild:streak z:10];
                [[(GamePlay *)[[[CCDirector sharedDirector] runningScene] getChildByTag:1] allBlood] addObject:streak];
                
                [streak release];
            }
        }
    }
    
    [self.wounds addObject:wound];
    [app.batchNode addChild:wound z:-1];
    
    [wound release];
}

- (void)createScabChunkAndBorderWithCenter:(CGPoint)scabChunkCenter type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority {
    ScabChunk *scabChunk = [self createScabChunk:scabChunkCenter type:type scabChunkNo:scabChunkNo priority:priority];
    [self createScabChunkBorderFromIScabSprite:scabChunk];
    
    [scabChunk release];
}

- (void)displaySprites {
    NSMutableArray *savedScabChunks = [self.scabChunks copy];
    NSMutableArray *savedScabChunkBorders = [self.scabChunkBorders copy];
    NSMutableArray *savedWounds = [self.wounds copy];

    [self.scabChunks removeAllObjects];
    [self.wounds removeAllObjects];
    [self.scabChunkBorders removeAllObjects];
    
    for (ScabChunk *scabChunk in savedScabChunks) {
        [self createScabChunk:scabChunk.savedLocation type:scabChunk.type scabChunkNo:scabChunk.scabChunkNo priority:scabChunk.priority];
    }
    
    for (Wound *scabChunkBorder in savedScabChunkBorders) {
        [self createScabChunkBorderFromIScabSprite:scabChunkBorder];
    }
    
    for (Wound *wound in savedWounds) {
        [self createWoundFromIScabSprite:wound isClean:wound.isClean];
    }
    
    [savedWounds release];
    [savedScabChunks release];
    [savedScabChunkBorders release];
}
   
- (void)reset {
   NSMutableArray *removedScabs = [NSMutableArray array];
   for (ScabChunk *scabChunk in [self scabChunks]) {
       [removedScabs addObject:scabChunk];
   }
   for (ScabChunk *removedScabChunk in removedScabs) {
       [removedScabChunk destroy];
   }
   [removedScabs removeAllObjects];
   scabChunks = nil;
    
   for (Wound *wound in [self wounds]) {
       [wound destroy];
   }
   wounds = nil;

   for (Wound *scabChunkBorder in [self scabChunkBorders]) {
       [scabChunkBorder destroy];
   }
   scabChunkBorders = nil;    
}
 
@end