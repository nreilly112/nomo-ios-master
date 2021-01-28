//
//  NMActivityIndicatorView.h
//  NoMo
//
//  Created by Costas Harizakis on 10/17/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NMActivityIndicatorView : UIView

@property (nonatomic, assign, getter = isAnimating) IBInspectable BOOL animating;
@property (nonatomic, assign) IBInspectable BOOL hidesWhenStopped;

- (void)startAnimating;
- (void)stopAnimating;

@end
