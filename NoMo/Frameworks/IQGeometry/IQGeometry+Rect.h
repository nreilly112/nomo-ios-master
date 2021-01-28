//
//  IQGeometry+Convenience.h
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import <Foundation/Foundation.h>

/*Set Origin*/
CGRect CGRectSetX(CGRect rect, CGFloat x);
CGRect CGRectSetY(CGRect rect, CGFloat y);
CGRect CGRectSetOrigin(CGRect rect, CGPoint origin);

/*Set Size*/
CGRect CGRectSetHeight(CGRect rect, CGFloat height);
CGRect CGRectSetWidth(CGRect rect, CGFloat width);
CGRect CGRectSetSize(CGRect rect, CGSize size);

/*Set Center*/
CGRect CGRectSetCenter(CGRect rect, CGPoint center);
CGPoint CGRectGetCenter(CGRect rect);
CGRect CGRectMakeWithOriginSize(CGPoint origin, CGSize size);
CGRect CGRectMakeWithCenterSize(CGPoint center, CGSize size);

/*Align*/
CGRect CGRectAlignCenterWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignCenterLeftWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignCenterRightWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignTopLeftWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignTopWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignTopRightWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignBottomLeftWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignBottomWithRect(CGRect rect, CGRect mainRect);
CGRect CGRectAlignBottomRightWithRect(CGRect rect, CGRect mainRect);

/*Rect from Points*/
CGRect CGRectMakeWithPoints(CGPoint startPoint, CGPoint endPoint);

/*Flip Rect Origin and Size*/
CGRect CGRectFlipHorizontal(CGRect rect, CGRect outerRect);
CGRect CGRectFlipVertical(CGRect rect, CGRect outerRect);
CGRect CGRectFlipFlop(CGRect rect);
// Does not affect size
CGRect CGRectFlipOrigin(CGRect rect);
// Does not affect point of origin
CGRect CGRectFlipSize(CGRect rect);

/*Scale*/
CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect CGRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect CGRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale);

/*Aspect Fit*/
CGRect CGRectAspectFit(CGSize sourceSize, CGRect destRect);
CGFloat CGAspectScaleFit(CGSize sourceSize, CGRect destRect);
// Only scales down, not up, and centers result
CGRect CGRectFitSizeInRect(CGSize sourceSize, CGRect destRect);

/*Aspect Fill*/
CGRect CGRectAspectFillRect(CGSize sourceSize, CGRect destRect);
CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect);

/*Crop*/
CGRect CGRectCropLeft(CGRect rect, CGFloat width);
CGRect CGRectCropRight(CGRect rect, CGFloat width);
CGRect CGRectCropTop(CGRect rect, CGFloat height);
CGRect CGRectCropBottom(CGRect rect, CGFloat height);

/*Crop*/
CGRect CGRectClipLeft(CGRect rect, CGFloat width);
CGRect CGRectClipRight(CGRect rect, CGFloat width);
CGRect CGRectClipTop(CGRect rect, CGFloat height);
CGRect CGRectClipBottom(CGRect rect, CGFloat height);
