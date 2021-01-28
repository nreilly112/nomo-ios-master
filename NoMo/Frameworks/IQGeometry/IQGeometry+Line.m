//
//  IQGeometry+CGLine.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Line.h"

CGLine CGLineMake(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2)
{
	return CGLineMakeWithPoints(CGPointMake(x1, y1), CGPointMake(x2, y2));
}

CGLine CGLineMakeWithPoints(CGPoint beginPoint, CGPoint endPoint)
{
    CGLine line; line.beginPoint = beginPoint; line.endPoint = endPoint; return line;
}


@implementation NSValue (Line)

+ (id)valueWithLine:(CGLine)line
{
    return [NSValue value:&line withObjCType:@encode(CGLine)];
}

- (CGLine)lineValue;
{
    CGLine line; [self getValue:&line]; return line;
}

@end