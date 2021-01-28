//
//  NMVerificationIndicatorView.m
//  NoMo
//
//  Created by Costas Harizakis on 06/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMVerificationIndicatorView.h"
#import "NMActivityIndicatorView.h"


@interface NMVerificationIndicatorView ()

@property (nonatomic, weak) IBOutlet NMActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end


@implementation NMVerificationIndicatorView

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self addContentSubview:[self contentViewFromNib]];
}

@end
