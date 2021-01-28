//
//  IQGeometry+CGSize.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

CGSize  CGSizeScale(CGSize aSize, CGFloat wScale, CGFloat hScale);

CGSize  CGSizeFlip(CGSize size);

CGSize  CGSizeFitInSize(CGSize sourceSize, CGSize destSize);

CGSize  CGSizeGetScale(CGSize sourceSize, CGSize destSize);
