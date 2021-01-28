//
//  UIView+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIView+Additions.h"


#define kUIViewHideDuration 0.5


@implementation UIView (Additions)

#pragma mark - [ Initializer ]

+ (instancetype)viewFromNib
{
	NSString *nibName = NSStringFromClass(self);
	
	return [self viewFromNibNamed:nibName owner:nil];
}

+ (instancetype)viewFromNibNamed:(NSString *)nibNameOrNil owner:(id)owner
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *nibName = nibNameOrNil ?: NSStringFromClass(self);
	NSArray *resources = [bundle loadNibNamed:nibName owner:owner options:nil];
	
	for (id resource in resources) {
		if ([resource isKindOfClass:[UIView class]]) {
			return resource;
		}
	}
	
	return nil;
}

- (UIView *)contentViewFromNib
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *nibName = NSStringFromClass(self.class);
	NSArray *resources = [bundle loadNibNamed:nibName owner:self options:nil];
	
	for (id resource in resources) {
		if ([resource isKindOfClass:[UIView class]]) {
			return resource;
		}
	}
	
	return nil;
}

- (void)insertContentSubview:(UIView *)subview atIndex:(NSInteger)index
{
	subview.translatesAutoresizingMaskIntoConstraints = NO;

	[self insertSubview:subview atIndex:0];
	[self updateConstraintsOfContentSubview:subview];
}

- (void)insertContentSubview:(UIView *)subview belowSubview:(UIView *)siblingSubview
{
	subview.translatesAutoresizingMaskIntoConstraints = NO;

	[self insertSubview:subview belowSubview:siblingSubview];
	[self updateConstraintsOfContentSubview:subview];
}

- (void)insertContentSubview:(UIView *)subview aboveSubview:(UIView *)siblingSubview
{
	subview.translatesAutoresizingMaskIntoConstraints = NO;

	[self insertSubview:subview aboveSubview:siblingSubview];
	[self updateConstraintsOfContentSubview:subview];
}

- (void)addContentSubview:(UIView *)subview
{
	subview.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self addSubview:subview];
	[self updateConstraintsOfContentSubview:subview];
}

- (void)addCenteredSubview:(UIView *)subview
{
	subview.translatesAutoresizingMaskIntoConstraints = NO;

	[self addSubview:subview];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:subview attribute:NSLayoutAttributeCenterX
													multiplier:1.0 constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:subview attribute:NSLayoutAttributeCenterY
													multiplier:1.0 constant:0.0]];
	[self setNeedsUpdateConstraints];
}

- (void)updateConstraintsOfContentSubview:(UIView *)subview
{
	NSDictionary *views = NSDictionaryOfVariableBindings(subview);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0@999)-[subview]-(0@999)-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0@999)-[subview]-(0@999)-|" options:0 metrics:nil views:views]];
	[self setNeedsUpdateConstraints];
}

#pragma mark - [ Properties ]

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}

- (CGFloat)right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)centerX
{
	return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
	self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY
{
	return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
	self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (CGFloat)screenX
{
	CGFloat x = 0;
	
	for (UIView* view = self; view; view = view.superview) {
		x += view.left;
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView* scrollView = (UIScrollView*)view;
			x -= scrollView.contentOffset.x;
		}
	}
	
	return x;
}

- (CGFloat)screenY
{
	CGFloat y = self.top;
	
	for (UIView* view = self.superview; view; view = view.superview) {
		y += view.top;
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView* scrollView = (UIScrollView*)view;
			y -= scrollView.contentOffset.y;
		}
	}
	
	return y;
}

- (CGRect)screenFrame
{
	return CGRectMake(self.screenX, self.screenY, self.width, self.height);
}

- (CGPoint)origin
{
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}

- (CGSize)size
{
	return self.frame.size;
}

- (void)setSize:(CGSize)size
{
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

#pragma mark - [ Methods ]

- (UIView *)previousSibling
{
	UIView *superview = self.superview;
	
	if (superview) {
		NSArray *subviews = superview.subviews;
		NSUInteger index = [subviews indexOfObject:self];
		
		if (0 < index) {
			return [subviews objectAtIndex:index - 1];
		}
	}
	
	return nil;
}

- (UIView *)previousSiblingWithClass:(Class)cls
{
	UIView *sibling = nil;
	UIView *superview = self.superview;
	
	if (superview) {
		NSArray *subviews = superview.subviews;
		NSUInteger count = subviews.count;
		
		for (NSUInteger index = 0; index < count; index++) {
			UIView *view = [subviews objectAtIndex:index];
			
			if (view == self) {
				break;
			}
			else if ([view isKindOfClass:cls]) {
				sibling = view;
			}
		}
	}
	
	return sibling;
}

- (UIView *)nextSibling
{
	UIView *superview = self.superview;
	
	if (superview) {
		NSArray *subviews = superview.subviews;
		NSUInteger index = [subviews indexOfObject:self];
		NSUInteger count = subviews.count;
		
		if (index < count - 1) {
			return [subviews objectAtIndex:index + 1];
		}
	}
	
	return nil;
}

- (UIView *)nextSiblingWithClass:(Class)cls
{
	UIView *sibling = nil;
	UIView *superview = self.superview;
	
	if (superview) {
		NSArray *subviews = superview.subviews;
		NSUInteger count = subviews.count;
		
		for (NSUInteger index = count; 0 < index; index--) {
			UIView *view = [subviews objectAtIndex:index - 1];
			
			if (view == self) {
				break;
			}
			else if ([view isKindOfClass:cls]) {
				sibling = view;
			}
		}
	}
	
	return sibling;
}

- (UIView *)descendantOrSelfWithClass:(Class)cls
{
	if ([self isKindOfClass:cls]) {
		return self;
	}
	
	for (UIView *child in self.subviews) {
		UIView *view = [child descendantOrSelfWithClass:cls];
		if (view) {
			return view;
		}
	}
	
	return nil;
}

- (UIView *)ancestorOrSelfWithClass:(Class)cls
{
	if ([self isKindOfClass:cls]) {
		return self;
	}
	else if (self.superview) {
		return [self.superview ancestorOrSelfWithClass:cls];
	}
	else {
		return nil;
	}
}

- (NSArray *)subviewsWithClass:(Class)cls
{
	NSMutableArray *subviews = [NSMutableArray array];
	
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:cls]) {
			[subviews addObject:subview];
		}
	}
	
	return subviews;
}

- (void)removeAllSubviews
{
	while (self.subviews.count) {
		UIView *view = self.subviews.lastObject;
		[view removeFromSuperview];
	}
}

- (UIView *)descendantOrSelfWithTag:(NSInteger)tag
{
	if (self.tag == tag) {
		return self;
	}
	
	for (UIView* child in self.subviews) {
		UIView *view = [child descendantOrSelfWithTag:tag];
		if (view) {
			return view;
		}
	}
	
	return nil;
}

- (UIImage *)snapshotImage
{
 	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
	
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
 
	return image;
}

@end


@implementation UIView (Presentation)

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self setHidden:hidden animated:animated completion:nil];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
	if (hidden) {
		void (^animations)(void) = ^(void) {
			self.alpha = 0.0;
		};
		void (^completion)(BOOL) = ^(BOOL finished) {
			if (finished) {
				self.hidden = YES;
			}
			if (completionHandler) {
				completionHandler(finished);
			}
		};
		
		if (animated) {
			[UIView animateWithDuration:kUIViewHideDuration
								  delay:0.0
								options:0 // UIViewAnimationOptionBeginFromCurrentState
							 animations:animations
							 completion:completion];
		}
		else {
			animations();
			completion(YES);
		}
	}
	else {
		void (^animations)(void) = ^(void) {
			self.alpha = 1.0;
		};
		void (^completion)(BOOL) = ^(BOOL finished) {
			if (completionHandler) {
				completionHandler(finished);
			}
		};

		if (self.hidden) {
			self.alpha = 0.0;
		}

		self.hidden = NO;

		[self setNeedsLayout];
		[self layoutIfNeeded];
		
		if (animated) {
			[UIView animateWithDuration:kUIViewHideDuration
								  delay:0.0
								options:0 // UIViewAnimationOptionBeginFromCurrentState
							 animations:animations
							 completion:completion];
		}
		else {
			animations();
			completion(YES);
		}
	}
}

@end


@implementation UIView (Appearance)

- (UIColor *)borderColor
{
	return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
	self.layer.borderColor = borderColor.CGColor;
}

- (CGFloat)borderWidth
{
	return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
	self.layer.borderWidth = borderWidth;
}

- (CGFloat)cornerRadius
{
	return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
	self.layer.cornerRadius = cornerRadius;
}

@end

