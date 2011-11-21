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
#import "SpecialScabs.h"
#import "AppDelegate.h"

@implementation Scab

@synthesize scabChunks, wounds, center, scabChunkBorders, birthday, sizeAtCreation, healDate, isAged, isOverpickWarningIssued, name;

- (int)pointValue {
    switch ([self scabSize]) {
        case XL_SCAB:
            return 4;
        case LARGE_SCAB:
            return 3;
        case MEDIUM_SCAB:
            return 2;
        case SMALL_SCAB:
            return 1;
        default:
            return 1;
    }
}

- (NSMutableArray *)randomScabChunksForOrigin:(CGPoint)scabOrigin withBoundary:(CGRect)backgroundBoundary {
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];

    CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, SPECIAL_SCAB_WIDTH_FOR_EXTRA_SCAB_CHUNKS, SPECIAL_SCAB_HEIGHT_FOR_EXTRA_SCAB_CHUNKS);

    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
    
    for (int x = 0; x < NUM_SPECIAL_SCAB_EXTRA_SCAB_CHUNKS; x++) { 
        [coordinates addObject:[NSValue valueWithCGPoint:[self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin]]];
    }
    
    return coordinates;
}

- (void)initializeStatesWithName:(NSString *)scabName {
    [self setName:scabName];
    [self setIsOverpickWarningIssued:NO];
    [self setSizeAtCreation:[self.scabChunks count]];
    
    NSLog(@"NUM SCAB CHUNKS IN THIS SCAB: %d", [self sizeAtCreation]);
    
    [self setBirthday:[NSDate date]];
    [self setHealDate:[[NSDate date] dateByAddingTimeInterval:[self healingInterval]]];
}

- (CGPoint)generateScabOrigin:(CGRect)backgroundBoundary {
    int scabXOffset = (arc4random() % (int)backgroundBoundary.size.width) + backgroundBoundary.origin.x;
    int scabYOffset = (arc4random() % (int)backgroundBoundary.size.height) + backgroundBoundary.origin.y;
    
    return CGPointMake(scabXOffset, scabYOffset);
}

- (id)createSpecialWithBackgroundBoundary:(CGRect)backgroundBoundary {
    if ((self = [super init])) {
        NSArray *specialScabNames = [SpecialScabs specialScabNames];
        NSString *specialScabName = [specialScabNames objectAtIndex:(arc4random() % ([specialScabNames count] - 1))];
        
        NSMutableArray *shapeCoordinates;
        
        shapeCoordinates = [self heartShapeCoordinates:backgroundBoundary];
        
        /*
        if ([specialScabName isEqualToString:@"xxx"]) {
            shapeCoordinates = [self xShapeCoordinates:backgroundBoundary];
        } else if ([specialScabName isEqualToString:@"sass"]) {
            shapeCoordinates = [self sassShapeCoordinates:backgroundBoundary];
        } else if ([specialScabName isEqualToString:@"jesus"]) {
            shapeCoordinates = [self jesusShapeCoordinates:backgroundBoundary];
        } else if ([specialScabName isEqualToString:@"heart"]) {       
            shapeCoordinates = [self heartShapeCoordinates:backgroundBoundary];
        } else if ([specialScabName isEqualToString:@"illuminati"]) {
            shapeCoordinates = [self illuminatiShapeCoordinates:backgroundBoundary];
        }*/
        
        for (int x = 0; x < [shapeCoordinates count]; x++) { 
            [self createScabChunkAndBorderWithCenter:[[shapeCoordinates objectAtIndex:x] CGPointValue] type:@"dark" scabChunkNo:(arc4random() % NUM_SHAPE_TYPES) priority:2];
        }
        
        [self initializeStatesWithName:specialScabName];
    }
    
    return self;
}

- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary {   
    if ((self = [super init])) {
        CGPoint scabOrigin = [self generateScabOrigin:backgroundBoundary];
        CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, (arc4random() % MAX_SCAB_WIDTH) + 1, (arc4random() % MAX_SCAB_HEIGHT) + 1);
        
        center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
        
        int numScabChunks = (scabBoundary.size.height + scabBoundary.size.width) * 2;         
        for (int x = 0; x < numScabChunks; x++) { 
            int scabChunkNo = arc4random() % NUM_SHAPE_TYPES;
            CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
         
            if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero))
                [self createScabChunkAndBorderWithCenter:scabChunkCenter type:@"light" scabChunkNo:scabChunkNo priority:1];
        }
         
        int numDarkPatches = (arc4random() % NUM_DARK_PATCHES);
        int maxDistanceToXEdge = (center.x - scabOrigin.x) + 1;
        int maxDistanceToYEdge = (center.y - scabOrigin.y) + 1;
        for (int x = 0; x < numDarkPatches; x++) {
            CGPoint patchOrigin = CGPointMake(
                (int)center.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
                (int)center.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
            );
         
            for (int x = 0; x < (numScabChunks / 4); x++) {
                int scabChunkNo = arc4random() % NUM_SHAPE_TYPES;
                CGPoint scabChunkCenter = [self getScabChunkCenterFrom:patchOrigin backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
             
                if (!CGPointEqualToPoint(scabChunkCenter, CGPointZero))
                    [self createScabChunkAndBorderWithCenter:scabChunkCenter type:@"dark" scabChunkNo:scabChunkNo priority:2];
            }
        }
        
        [self initializeStatesWithName:@"standard"];
    }
    
    return self;
}
    
- (CGPoint)getScabChunkCenterFrom:(CGPoint)scabCenter backgroundBoundary:(CGRect)backgroundBoundary scabBoundary:(CGRect)scabBoundary scabOrigin:(CGPoint)scabOrigin {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    int maxDistanceToXEdge = (center.x - scabOrigin.x) + 1;
    int maxDistanceToYEdge = (center.y - scabOrigin.y) + 1;

    CGPoint scabChunkCenter = CGPointMake(
        (int)scabCenter.x + (int)(arc4random() % (maxDistanceToXEdge * 2) - maxDistanceToXEdge), 
        (int)scabCenter.y + (int)(arc4random() % (maxDistanceToYEdge * 2) - maxDistanceToYEdge)
    );
    
    if (
        CGRectContainsPoint(backgroundBoundary, scabChunkCenter)          && // is inside background boundaries
        CGRectContainsPoint(scabBoundary, scabChunkCenter)                && // is inside scab boundaries
        !CGRectContainsPoint(app.backButton.boundingBox, scabChunkCenter) && // is not inside the back icon
        !CGRectContainsPoint(app.jarButton.boundingBox, scabChunkCenter)     // is not inside the jar icon
    )
        return scabChunkCenter;
     
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
    
    bool isBleeding = (!isClean && (arc4random() % ((int)ceil(ccpDistance([app centerOfAllScabs], iscabSprite.savedLocation) * 0.10) + 1) == 2)) ? TRUE : FALSE;
    NSString *woundType = [Wound woundFrameNameForClean:isClean isBleeding:isBleeding scabChunkNo:iscabSprite.scabChunkNo];
    
    Wound *wound = [[Wound alloc] initWithSpriteFrameName:woundType];
    [wound setPosition:iscabSprite.savedLocation];
    [wound setSavedLocation:iscabSprite.savedLocation];
    [wound setScabChunkNo:iscabSprite.scabChunkNo];
    [wound setIsClean:isClean];
    [wound setIsBleeding:isBleeding];
    [wound setScale:0.8];
    
    /*
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
    }*/
    
    [self.wounds addObject:wound];
    [app.batchNode addChild:wound z:-1];
    
    [wound release];
}

- (void)createScabChunkAndBorderWithCenter:(CGPoint)scabChunkCenter type:(NSString *)type scabChunkNo:(int)scabChunkNo priority:(int)priority {
    ScabChunk *scabChunk = [self createScabChunk:scabChunkCenter type:type scabChunkNo:scabChunkNo priority:priority];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[app.defaults objectForKey:@"skinColor"] isEqualToString:@"light"]) {
        [self createScabChunkBorderFromIScabSprite:scabChunk];
    }
    
    [scabChunk release];
}

- (void)displaySprites {
    NSLog(@"DISPLAYING SPRITES");
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
    
    bool shouldHealUncleanWounds = [[self healDate] compare:[NSDate date]] == NSOrderedAscending ? TRUE : FALSE;
    for (Wound *wound in savedWounds) {
        if (shouldHealUncleanWounds) {
            if (!wound.isClean)
                [self createScabChunk:wound.savedLocation type:@"light" scabChunkNo:wound.scabChunkNo priority:1];
            [self createWoundFromIScabSprite:wound isClean:TRUE];
        } else {
            [self createWoundFromIScabSprite:wound isClean:wound.isClean];
        }
    }
    
    [savedWounds release];
    [savedScabChunks release];
    [savedScabChunkBorders release];
}

- (int)scabSize {
    if (self.sizeAtCreation >= XL_SCAB_SIZE) {
        return XL_SCAB;
    } else if (self.sizeAtCreation >= LARGE_SCAB_SIZE) {
        return LARGE_SCAB;
    } else if (self.sizeAtCreation >= MEDIUM_SCAB_SIZE) {
        return MEDIUM_SCAB;
    } else {
        return SMALL_SCAB;
    }
}

- (int)baseHealingInterval {
    switch ([self scabSize]) {
        case XL_SCAB:
            return XL_HEALING_TIME;
        case LARGE_SCAB:
            return LARGE_HEALING_TIME;
        case MEDIUM_SCAB:
            return MEDIUM_HEALING_TIME;
        case SMALL_SCAB:
            return SMALL_HEALING_TIME;
        default:
            return XL_HEALING_TIME;
    }
}

- (NSTimeInterval)maximumHealingInterval {
    return [self baseHealingInterval] * 2;
}
         
- (NSTimeInterval)healingInterval {
    return [self baseHealingInterval] + (arc4random() % [self baseHealingInterval]);
}

- (bool)isComplete {
    if ([self.scabChunks count])
        return false;
    
    for (Wound *wound in self.wounds) {
        if (!wound.isClean)
            return false;
    }
    
    return true;
}

- (bool)isOverpicked {
    if (isAged) {
        return false;
    } else if (((float)[self.wounds count] / (float)self.sizeAtCreation) >= OVERPICKED_THRESHOLD) {
        return true;
    } else {
        return false;
    }
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

#pragma singletons

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

#pragma encode/decode

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.scabChunks forKey:@"scabChunks"];
    [coder encodeObject:self.scabChunkBorders forKey:@"scabChunkBorders"];
    [coder encodeObject:self.wounds forKey:@"wounds"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
    [coder encodeObject:self.healDate forKey:@"healDate"];
    [coder encodeInt:self.sizeAtCreation forKey:@"sizeAtCreation"];
    [coder encodeBool:self.isAged forKey:@"isAged"];
    [coder encodeBool:self.isOverpickWarningIssued forKey:@"isOverpickWarningIssued"];
    [coder encodeObject:(NSString *)self.name forKey:@"name"];
} 

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Scab alloc] init];
    
    if (self != nil) {
        self.scabChunks = (NSMutableArray *)[coder decodeObjectForKey:@"scabChunks"];
        self.scabChunkBorders = (NSMutableArray *)[coder decodeObjectForKey:@"scabChunkBorders"];
        self.wounds = (NSMutableArray *)[coder decodeObjectForKey:@"wounds"];
        self.birthday = (NSDate *)[coder decodeObjectForKey:@"birthday"];
        self.healDate = (NSDate *)[coder decodeObjectForKey:@"healDate"];
        self.sizeAtCreation = [coder decodeIntForKey:@"sizeAtCreation"];
        self.isAged = [coder decodeBoolForKey:@"isAged"];
        self.isOverpickWarningIssued = [coder decodeBoolForKey:@"isOverpickWarningIssued"];
        self.name = (NSString *)[coder decodeObjectForKey:@"name"];
    }
    
    NSLog(@"LOADED NUMBER OF SCAB CHUNKS: %d", [self.scabChunks count]);
    NSLog(@"LOADED NUMBER OF SCAB BORDERS: %d", [self.scabChunkBorders count]);
    NSLog(@"LOADED NUMBER OF SCAB WOUNDS: %d", [self.wounds count]);
    NSLog(@"LOADED SCAB SIZE AT CREATION: %d", [self sizeAtCreation]);
    NSLog(@"LOADED SCAB BIRTHDAY: %@", [self birthday]);
    NSLog(@"LOADED SCAB HEAL DATE: %@", [self healDate]);
    NSLog(@"IS AGED: %d", (int)[self isAged]);
    NSLog(@"NAME: %@", [self name]);
    
    return self; 
}

#pragma special scab coordinates

- (NSMutableArray *)heartShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin:backgroundBoundary];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, ILLUMINATI_SCAB_SIZE, ILLUMINATI_SCAB_SIZE);
    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));

    CGPoint bottom = CGPointMake((HEART_SCAB_SIZE / 2) + scabOrigin.x, scabOrigin.y);
    CGPoint left = CGPointMake(scabOrigin.x, HEART_SCAB_SIZE + scabOrigin.y);
    CGPoint right = CGPointMake(ILLUMINATI_SCAB_SIZE + scabOrigin.x, HEART_SCAB_SIZE + scabOrigin.y);
    
    for (int x = 0; x < HEART_SCAB_SIZE * 10; x++) { 
        CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
        
        if (
            !CGPointEqualToPoint(scabChunkCenter, CGPointZero) &&
            [Scab gbPointInTriangle:scabChunkCenter pointA:left pointB:bottom pointC:right]
        )
            [coordinates addObject:[NSValue valueWithCGPoint:scabChunkCenter]];
    }
    
    CGPoint leftHeart = CGPointMake(scabOrigin.x + (HEART_SCAB_SIZE / 4), (HEART_SCAB_SIZE + scabOrigin.y));
    CGPoint rightHeart = CGPointMake(scabOrigin.x + HEART_SCAB_SIZE, (HEART_SCAB_SIZE + scabOrigin.y));
    for (int i = 0; i < 5000; i++) {
        CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
        
        if (
            !CGPointEqualToPoint(scabChunkCenter, CGPointZero) &&
            (
             (ccpLengthSQ(ccpSub(leftHeart, scabChunkCenter)) < (HEART_TOP_RADIUS * HEART_TOP_RADIUS)) ||
             (ccpLengthSQ(ccpSub(rightHeart, scabChunkCenter)) < (HEART_TOP_RADIUS * HEART_TOP_RADIUS))
            )
        )
            [coordinates addObject:[NSValue valueWithCGPoint:scabChunkCenter]];
    }

    return coordinates;
}

- (NSMutableArray *)illuminatiShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin:backgroundBoundary];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, ILLUMINATI_SCAB_SIZE, ILLUMINATI_SCAB_SIZE);
    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
    
    CGPoint eyeCenter = CGPointMake(scabOrigin.x + (ILLUMINATI_SCAB_SIZE / 2), (ILLUMINATI_SCAB_SIZE + scabOrigin.y) - 30);
    
    CGPoint top = CGPointMake((ILLUMINATI_SCAB_SIZE / 2) + scabOrigin.x, ILLUMINATI_SCAB_SIZE + scabOrigin.y);
    CGPoint left = CGPointMake(scabOrigin.x, scabOrigin.y);
    CGPoint right = CGPointMake(ILLUMINATI_SCAB_SIZE + scabOrigin.x, scabOrigin.y);
    
    for (int x = 0; x < ILLUMINATI_SCAB_SIZE * 10; x++) { 
        CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
        
        if (
            !CGPointEqualToPoint(scabChunkCenter, CGPointZero) &&
            [Scab gbPointInTriangle:scabChunkCenter pointA:left pointB:top pointC:right] &&
            (ccpLengthSQ(ccpSub(eyeCenter, scabChunkCenter)) > (ILLUMINATI_EYE_RADIUS * ILLUMINATI_EYE_RADIUS))
        )
            [coordinates addObject:[NSValue valueWithCGPoint:scabChunkCenter]];
    }
    
    [coordinates addObject:[NSValue valueWithCGPoint:eyeCenter]];
    
    return coordinates;
}

- (NSMutableArray *)xShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin:backgroundBoundary];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    
    for (int xNumber = 0; xNumber < 3; xNumber++) {    
        int topSwipeLocation = XXX_SCAB_SIZE;
        for (int bottomSwipeLocation = 0; bottomSwipeLocation < XXX_SCAB_SIZE; bottomSwipeLocation++) {
            int adjustedBottomSwipeLocation = bottomSwipeLocation + (xNumber * XXX_SCAB_SIZE);
            
            [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(
                                                                         adjustedBottomSwipeLocation + scabOrigin.x, 
                                                                         bottomSwipeLocation + scabOrigin.y
                                                                         )]];
            [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(
                                                                         adjustedBottomSwipeLocation + scabOrigin.x,
                                                                         topSwipeLocation + scabOrigin.y
                                                                         )]];
            
            topSwipeLocation--;
        }
    }
    
    [coordinates addObjectsFromArray:[self randomScabChunksForOrigin:scabOrigin withBoundary:backgroundBoundary]];
    
    return coordinates;
}

+ (CGFloat)gbDotWithV1:(CGPoint)v1 v2:(CGPoint)v2 {
	return v1.x * v2.x + v1.y * v2.y;
}

+ (CGPoint)gbSubWithV1:(CGPoint)v1 v2:(CGPoint)v2 {
	return CGPointMake(v1.x - v2.x, v1.y - v2.y);
}

+ (BOOL)gbPointInTriangle:(CGPoint)point pointA:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC {  
    //http://www.blackpawn.com/texts/pointinpoly/default.html
	CGPoint v0 = [self gbSubWithV1:pointC v2:pointA];
	CGPoint v1 = [self gbSubWithV1:pointB v2:pointA];
    CGPoint v2 = [self gbSubWithV1:point v2:pointA];
    
	CGFloat dot00 = [self gbDotWithV1:v0 v2:v0];
	CGFloat dot01 = [self gbDotWithV1:v0 v2:v1];
	CGFloat dot02 = [self gbDotWithV1:v0 v2:v2];
	CGFloat dot11 = [self gbDotWithV1:v1 v2:v1];
	CGFloat dot12 = [self gbDotWithV1:v1 v2:v2];
    
	CGFloat invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
	CGFloat u = (dot11 * dot02 - dot01 * dot12) * invDenom;
	CGFloat v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
	return (u > 0) && (v > 0) && (u + v < 1);
}
 
@end