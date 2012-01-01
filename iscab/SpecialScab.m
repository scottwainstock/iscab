//
//  SpecialScab.m
//  iscab
//
//  Created by Scott Wainstock on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpecialScab.h"
#import "SpecialScabs.h"

@implementation SpecialScab

- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary {
    if ((self = [super init])) {
        NSString *specialScabName = [[SpecialScabs specialScabNames] objectAtIndex:(arc4random() % ([[SpecialScabs specialScabNames] count] - 1))];
        
        NSMutableArray *shapeCoordinates = nil;
        
        if ([specialScabName isEqualToString:@"xxx"])
            shapeCoordinates = [self xShapeCoordinates:backgroundBoundary];
        else if ([specialScabName isEqualToString:@"sass"])
            shapeCoordinates = [self sassShapeCoordinates:backgroundBoundary];
        else if ([specialScabName isEqualToString:@"jesus"])
            shapeCoordinates = [self jesusShapeCoordinates:backgroundBoundary];
        else if ([specialScabName isEqualToString:@"heart"])    
            shapeCoordinates = [self heartShapeCoordinates:backgroundBoundary];
        else if ([specialScabName isEqualToString:@"illuminati"])
            shapeCoordinates = [self illuminatiShapeCoordinates:backgroundBoundary];
        
        [shapeCoordinates retain];
        
        for (NSValue *point in shapeCoordinates)
            if (!CGPointEqualToPoint([point CGPointValue], CGPointZero))
                [self createScabChunkAndBorderWithCenter:[point CGPointValue] type:@"dark" scabChunkNo:(arc4random() % NUM_SHAPE_TYPES) priority:2];
        
        [self initializeStatesWithName:specialScabName];
        [shapeCoordinates release];
    }
    
    return self;
}

- (CGPoint)generateScabOrigin {
    return CGPointMake((arc4random() % 2 == 1) ? 75 : 125, (arc4random() % 2 == 1) ? 50 : 75);
}

- (NSMutableArray *)jesusShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin];
    CGRect scabBoundary = CGRectMake((int)scabOrigin.x - JESUS_SCAB_SIZE, (int)scabOrigin.y - JESUS_SCAB_SIZE, 200, 200);
    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
    
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
    
    //face loops
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:35 xMidPoint:scabOrigin.x yMidPoint:scabOrigin.y]];
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:30 xMidPoint:scabOrigin.x yMidPoint:scabOrigin.y]];
    
    //left eye
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 3, scabOrigin.y + 4)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 6, scabOrigin.y + 6)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 9, scabOrigin.y + 8)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 12, scabOrigin.y + 6)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 15, scabOrigin.y + 4)]];
    
    //right eye
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y + 4)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 14, scabOrigin.y + 6)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 17, scabOrigin.y + 8)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 20, scabOrigin.y + 6)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 23, scabOrigin.y + 4)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y + 1)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y - 2)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y - 5)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y - 8)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 11, scabOrigin.y - 11)]];
    
    //stache
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 30, scabOrigin.y - 20)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 25, scabOrigin.y - 18)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 20, scabOrigin.y - 17)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 15, scabOrigin.y - 16)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 10, scabOrigin.y - 14)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 5, scabOrigin.y - 12)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x - 2, scabOrigin.y - 11)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x, scabOrigin.y - 10)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 2, scabOrigin.y - 11)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 5, scabOrigin.y - 12)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 10, scabOrigin.y - 14)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 15, scabOrigin.y - 16)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 20, scabOrigin.y - 17)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 25, scabOrigin.y - 18)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(scabOrigin.x + 30, scabOrigin.y - 20)]];
    
    //beard
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:15 xMidPoint:scabOrigin.x yMidPoint:scabOrigin.y - 30]];
    
    //hair
    [coordinates addObjectsFromArray:[self drawEarWithTop:CGPointMake(scabOrigin.x - 40, scabOrigin.y + 30) left:CGPointMake(scabOrigin.x - 55, scabOrigin.y - 60) right:CGPointMake(scabOrigin.x, scabOrigin.y - 35)]];
    [coordinates addObjectsFromArray:[self drawEarWithTop:CGPointMake(scabOrigin.x + 35, scabOrigin.y + 5) left:CGPointMake(scabOrigin.x + 5, scabOrigin.y - 55) right:CGPointMake(scabOrigin.x + 65, scabOrigin.y - 55)]];
    
    [coordinates addObjectsFromArray:[self randomScabChunksForOrigin:CGPointMake(scabOrigin.x - JESUS_SCAB_SIZE, scabOrigin.y - JESUS_SCAB_SIZE) withBoundary:scabBoundary]];
    
    return coordinates;
}


- (NSMutableArray *)heartShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin];
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
    CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, HEART_SCAB_SIZE, HEART_SCAB_SIZE);
    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
    
    CGPoint bottom = CGPointMake((HEART_SCAB_SIZE / 2) + scabOrigin.x, scabOrigin.y);
    CGPoint left = CGPointMake(scabOrigin.x, HEART_SCAB_SIZE + scabOrigin.y);
    CGPoint right = CGPointMake(HEART_SCAB_SIZE + scabOrigin.x, HEART_SCAB_SIZE + scabOrigin.y);
    
    for (int x = 0; x < HEART_SCAB_SIZE * 10; x++) { 
        CGPoint scabChunkCenter = [self getScabChunkCenterFrom:center backgroundBoundary:backgroundBoundary scabBoundary:scabBoundary scabOrigin:scabOrigin];
        
        if (
            !CGPointEqualToPoint(scabChunkCenter, CGPointZero) &&
            [SpecialScab gbPointInTriangle:scabChunkCenter pointA:left pointB:bottom pointC:right]
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
    CGPoint scabOrigin = [self generateScabOrigin];
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
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
            [SpecialScab gbPointInTriangle:scabChunkCenter pointA:left pointB:top pointC:right] &&
            (ccpLengthSQ(ccpSub(eyeCenter, scabChunkCenter)) > (ILLUMINATI_EYE_RADIUS * ILLUMINATI_EYE_RADIUS))
            )
            [coordinates addObject:[NSValue valueWithCGPoint:scabChunkCenter]];
    }
    
    [coordinates addObject:[NSValue valueWithCGPoint:eyeCenter]];
    
    return coordinates;
}

- (NSMutableArray *)xShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin];
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
    
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

- (NSMutableArray *)sassShapeCoordinates:(CGRect)backgroundBoundary {
    CGPoint scabOrigin = [self generateScabOrigin];
    CGRect scabBoundary = CGRectMake((int)scabOrigin.x, (int)scabOrigin.y, SASS_SCAB_SIZE, SASS_SCAB_SIZE);
    center = CGPointMake((int)scabBoundary.origin.x + (int)(scabBoundary.size.width / 2), (int)scabBoundary.origin.y + (int)(scabBoundary.size.height / 2));
    
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
    
    //face loops
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:40 xMidPoint:scabOrigin.x yMidPoint:scabOrigin.y]];
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:35 xMidPoint:scabOrigin.x yMidPoint:scabOrigin.y]];
    
    //left eye
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:5 xMidPoint:(scabOrigin.x - 15) yMidPoint:(scabOrigin.y + 5)]];
    
    //right eye
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:5 xMidPoint:(scabOrigin.x + 15) yMidPoint:(scabOrigin.y + 5)]];
    
    //beard
    [coordinates addObjectsFromArray:[self drawCircleWithRadius:5 xMidPoint:(scabOrigin.x + 5) yMidPoint:(scabOrigin.y - 25)]];
    
    [coordinates addObjectsFromArray:[self drawEarWithTop:CGPointMake(scabOrigin.x - 45, scabOrigin.y + 65) left:CGPointMake(scabOrigin.x - 40, scabOrigin.y + 20) right:CGPointMake(scabOrigin.x - 10, scabOrigin.y + 40)]];
    [coordinates addObjectsFromArray:[self drawEarWithTop:CGPointMake(scabOrigin.x + 45, scabOrigin.y + 60) left:CGPointMake(scabOrigin.x + 20, scabOrigin.y + 30) right:CGPointMake(scabOrigin.x + 35, scabOrigin.y + 25)]];
    
    [coordinates addObjectsFromArray:[self randomScabChunksForOrigin:CGPointMake(scabOrigin.x - 40, scabOrigin.y - 40) withBoundary:backgroundBoundary]];
    
    return coordinates;
}

- (NSMutableArray *)drawEarWithTop:(CGPoint)top left:(CGPoint)left right:(CGPoint)right {
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    
    CGPoint earCenter = CGPointMake((int)((top.x + left.x + right.x) / 3), (int)((top.y + left.y + right.y) / 3));    
    for (int x = 0; x < 400; x++) { 
        CGPoint scabChunkCenter = [self getScabChunkCenterFrom:earCenter backgroundBoundary:CGRectMake(left.x, left.y, 300, 300) scabBoundary:CGRectMake(left.x, left.y, 300, 300) scabOrigin:earCenter];
        
        if (
            !CGPointEqualToPoint(scabChunkCenter, CGPointZero) &&
            [SpecialScab gbPointInTriangle:scabChunkCenter pointA:left pointB:top pointC:right]
            )
            [coordinates addObject:[NSValue valueWithCGPoint:scabChunkCenter]];
    }
    
    return coordinates;
}

- (NSMutableArray *)drawCircleWithRadius:(int)radius xMidPoint:(int)xMidPoint yMidPoint:(int)yMidPoint {
    NSMutableArray *coordinates = [[[NSMutableArray alloc] init] autorelease];
    
    int f = 1 - radius;
    int ddF_x = 1;
    int ddF_y = -2 * radius;
    int x = 0;
    int y = radius;
    
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint, yMidPoint + radius)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint, yMidPoint - radius)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint + radius, yMidPoint)]];
    [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint - radius, yMidPoint)]];
    
    while(x < y){
        if(f >= 0) {
            y--;
            ddF_y += 2;
            f += ddF_y;
        }
        
        x++;
        ddF_x += 2;
        f += ddF_x;    
        
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint + x, yMidPoint + y)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint + y, yMidPoint + x)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint - x, yMidPoint + y)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint - y, yMidPoint + x)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint + x, yMidPoint - y)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint + y, yMidPoint - x)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint - x, yMidPoint - y)]];
        [coordinates addObject:[NSValue valueWithCGPoint:CGPointMake(xMidPoint - y, yMidPoint - x)]];
    }
    
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