//
//  IQGeometry+Convenience.m
//  Geometry Extension
//
//  Created by Iftekhar Mac Pro on 8/25/13.
//  Copyright (c) 2013 Iftekhar. All rights reserved.
//

#import "IQGeometry+Rect.h"
#import "IQGeometry+Size.h"

CGRect CGRectSetX(CGRect rect, CGFloat x)
{
    rect.origin.x = x;  return rect;
}

CGRect CGRectSetY(CGRect rect, CGFloat y)
{
    rect.origin.y = y;  return rect;
}

CGRect CGRectSetOrigin(CGRect rect, CGPoint origin)
{
    rect.origin = origin;   return rect;
}


CGRect CGRectSetWidth(CGRect rect, CGFloat width)
{
    rect.size.width =   width;  return rect;
}

CGRect CGRectSetHeight(CGRect rect, CGFloat height)
{
    rect.size.height = height;  return rect;
}

CGRect CGRectSetSize(CGRect rect, CGSize size)
{
    rect.size = size;   return rect;
}


CGRect CGRectMakeWithPoints(CGPoint startPoint, CGPoint endPoint)
{
    return CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y);
}

CGRect CGRectSetCenter(CGRect rect, CGPoint center)
{
    return CGRectMake(center.x-CGRectGetWidth(rect)/2, center.y-CGRectGetHeight(rect)/2, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

CGRect CGRectMakeWithOriginSize(CGPoint origin, CGSize size)
{
	CGRect rect = { origin, size }; return rect;
}

CGRect CGRectMakeWithCenterSize(CGPoint center, CGSize size)
{
	return CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
}


CGRect CGRectAlignCenterWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignCenterLeftWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMinX(mainRect)-CGRectGetMinX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignCenterRightWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMaxX(mainRect)-CGRectGetMaxX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignTopLeftWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMinX(mainRect)-CGRectGetMinX(rect);
    CGFloat dy = CGRectGetMinY(mainRect)-CGRectGetMinY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignTopWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMinY(mainRect)-CGRectGetMinY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignTopRightWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMaxX(mainRect)-CGRectGetMaxX(rect);
    CGFloat dy = CGRectGetMinY(mainRect)-CGRectGetMinY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignBottomLeftWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMinX(mainRect)-CGRectGetMinX(rect);
    CGFloat dy = CGRectGetMaxY(mainRect)-CGRectGetMaxY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignBottomWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMaxY(mainRect)-CGRectGetMaxY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGRect CGRectAlignBottomRightWithRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMaxX(mainRect)-CGRectGetMaxX(rect);
    CGFloat dy = CGRectGetMaxY(mainRect)-CGRectGetMaxY(rect);
	return CGRectOffset(rect, dx, dy);
}


CGRect CGRectFlipHorizontal(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.x = outerRect.origin.x + outerRect.size.width - (rect.origin.x + rect.size.width);
    return rect;
}

CGRect CGRectFlipVertical(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.y = outerRect.origin.y + outerRect.size.height - (rect.origin.y + rect.size.height);
    return rect;
}

CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect CGRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect  CGRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width, rect.size.height);
}

CGRect CGRectFitSizeInRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGSize targetSize = CGSizeFitInSize(sourceSize, destSize);
	float dWidth = destSize.width - targetSize.width;
	float dHeight = destSize.height - targetSize.height;
    
	return CGRectMake(destRect.origin.x + dWidth / 2.0f, destRect.origin.y + dHeight / 2.0f, targetSize.width, targetSize.height);
}

CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MAX(scaleW, scaleH);
}

CGRect CGRectAspectFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFit(sourceSize, destRect);
    
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
    
	float dWidth = destSize.width - newWidth;
	float dHeight = destSize.height - newHeight;
    
	return CGRectMake(destRect.origin.x + dWidth / 2.0f, destRect.origin.y + dHeight / 2.0f, newWidth, newHeight);
}

CGFloat CGAspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height;
    return MIN(scaleW, scaleH);
}

CGRect CGRectAspectFillRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFill(sourceSize, destRect);
    
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
    
	float dWidth = destSize.width - newWidth;
	float dHeight = destSize.height - newHeight;
    
	return CGRectMake(destRect.origin.x + dWidth / 2.0f, destRect.origin.y + dHeight / 2.0f, newWidth, newHeight);
}

CGRect CGRectFlipFlop(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

CGRect CGRectFlipSize(CGRect rect)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

CGRect  CGRectFlipOrigin(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.width, rect.size.height);
}


CGRect CGRectCropLeft(CGRect rect, CGFloat width)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, width, CGRectMinXEdge); return slice;
}

CGRect CGRectCropRight(CGRect rect, CGFloat width)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, width, CGRectMaxXEdge); return slice;
}

CGRect CGRectCropTop(CGRect rect, CGFloat height)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, height, CGRectMinYEdge); return slice;
}

CGRect CGRectCropBottom(CGRect rect, CGFloat height)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, height, CGRectMaxYEdge); return slice;
}


CGRect CGRectClipLeft(CGRect rect, CGFloat width)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, width, CGRectMinXEdge); return remainder;
}

CGRect CGRectClipRight(CGRect rect, CGFloat width)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, width, CGRectMaxXEdge); return remainder;
}

CGRect CGRectClipTop(CGRect rect, CGFloat height)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, height, CGRectMinYEdge); return remainder;
}

CGRect CGRectClipBottom(CGRect rect, CGFloat height)
{
	CGRect slice, remainder; CGRectDivide(rect, &slice, &remainder, height, CGRectMaxYEdge); return remainder;
}




