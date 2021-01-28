//
//  IQGeometry+CGPoint.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQGeometry+Line.h"

CGPoint CGPointGetMidPoint(CGPoint point1, CGPoint point2);

/*  (x1,y1)         (x,y)                           (x2,y2) */
/*  *-----------------*----------------------------------*  */
/*  <----distance----->                                     */
//Returns a point(x,y) lies between point1(x1,y1) and point2(x2,y2) by distance from point1(x1,y1).
CGPoint CGPointInterpolate(CGPoint point1, CGPoint point2, CGFloat distance);

/*
line1.beginPoint   line2.endPoint
            \        /
              \    /
                \/
                /\
              /    \
            /        \
 line2.beginPoint   line1.endPoint
 */
CGPoint CGPointOfIntersect(CGLine line1, CGLine line2);

CGFloat CGPointGetDistanceOfPoint(CGPoint point, CGLine line);

/* Centroid of points, A, B and C is (x1+x2+x3)/3, (y1+y2+y3)/3 */
CGPoint CGPointCentroidOfPoints(NSArray* points);

CGPoint CGPointRotate(CGPoint basePoint,CGPoint point, CGFloat angle);

CGPoint CGPointGetNearPoint(CGPoint basePoint, NSArray *points);

CGPoint CGPointFlipHorizontal(CGPoint point, CGRect outerRect);

CGPoint CGPointFlipVertical(CGPoint point, CGRect outerRect);

CGPoint CGPointAspectFill(CGPoint point, CGSize destSize, CGRect sourceRect);

CGPoint CGPointOffset(CGPoint aPoint, CGFloat dx, CGFloat dy);

CGPoint CGPointScale(CGPoint aPoint, CGFloat wScale, CGFloat hScale);

// Flipping coordinates
CGPoint CGPointFlip(CGPoint point);






