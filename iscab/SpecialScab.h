//
//  SpecialScab.h
//  iscab
//
//  Created by Scott Wainstock on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scab.h"

#define JESUS_SCAB_SIZE 60
#define HEART_SCAB_SIZE 60
#define HEART_TOP_RADIUS 10
#define XXX_SCAB_SIZE 30
#define SASS_SCAB_SIZE 100
#define ILLUMINATI_SCAB_SIZE 80
#define ILLUMINATI_EYE_RADIUS (ILLUMINATI_SCAB_SIZE / 8)

@interface SpecialScab : Scab {
}

+ (BOOL)gbPointInTriangle:(CGPoint)point pointA:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC;

- (id)createWithBackgroundBoundary:(CGRect)backgroundBoundary;
- (NSMutableArray *)drawEarWithTop:(CGPoint)top left:(CGPoint)left right:(CGPoint)right;
- (NSMutableArray *)drawCircleWithRadius:(int)radius xMidPoint:(int)xMidPoint yMidPoint:(int)yMidPoint;
- (NSMutableArray *)illuminatiShapeCoordinates:(CGRect)backgroundBoundary;
- (NSMutableArray *)xShapeCoordinates:(CGRect)backgroundBoundary;
- (NSMutableArray *)heartShapeCoordinates:(CGRect)backgroundBoundary;
- (NSMutableArray *)sassShapeCoordinates:(CGRect)backgroundBoundary;
- (NSMutableArray *)jesusShapeCoordinates:(CGRect)backgroundBoundary;

@end