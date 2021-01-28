//
//  IQGeometry+CGLine.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

struct CGLine {
    CGPoint beginPoint;
    CGPoint endPoint;
};
typedef struct CGLine CGLine;

CGLine CGLineMake(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2);

CGLine CGLineMakeWithPoints(CGPoint beginPoint, CGPoint endPoint);



@interface NSValue (Line)

+ (id)valueWithLine:(CGLine)line;

- (CGLine)lineValue;

@end
