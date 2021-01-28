//
//  UIView+Additions.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface UIView (Additions)

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign, readonly) CGFloat screenX;
@property (nonatomic, assign, readonly) CGFloat screenY;
@property (nonatomic, assign, readonly) CGRect screenFrame;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

+ (instancetype)viewFromNib;
+ (instancetype)viewFromNibNamed:(NSString *)nibNameOrNil owner:(id)owner;

- (UIView *)contentViewFromNib;

- (void)insertContentSubview:(UIView *)contentView atIndex:(NSInteger)index;
- (void)insertContentSubview:(UIView *)contentView belowSubview:(UIView *)siblingSubview;
- (void)insertContentSubview:(UIView *)contentView aboveSubview:(UIView *)siblingSubview;
- (void)addContentSubview:(UIView *)contentView;
- (void)addCenteredSubview:(UIView *)contentView;

- (UIView *)previousSibling;
- (UIView *)nextSibling;
- (UIView *)previousSiblingWithClass:(Class)cls;
- (UIView *)nextSiblingWithClass:(Class)cls;
- (UIView *)descendantOrSelfWithClass:(Class)cls;
- (UIView *)ancestorOrSelfWithClass:(Class)cls;
- (NSArray *)subviewsWithClass:(Class)cls;
- (void)removeAllSubviews;

- (UIView *)descendantOrSelfWithTag:(NSInteger)tag;

- (UIImage *)snapshotImage;

@end


@interface UIView (Presentation)

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler;

@end


@interface UIView (Appearance)

@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

@end

