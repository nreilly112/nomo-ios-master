//
//  NMMainSummaryDisplayController.m
//  NoMo
//
//  Created by Costas Harizakis on 10/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMMainSummaryDisplayController.h"


@interface NMMainSummaryDisplayController ()

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *bankAccountBalanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *fundsBalanceLabel;

@end


@implementation NMMainSummaryDisplayController

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
}

#pragma mark - [ NMMainDisplayController Methods ]

- (void)reloadDataAnimated:(BOOL)animated
{
	[super reloadDataAnimated:animated];

	void (^updateViewState)(void) = ^(void) {
		[self updateTitle];
		[self updateSubtitle];
		[self updateAmount];
		[self updateComment];
		[self updateBankAccountBalance];
		[self updateFundsBalance];
	};
	
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			self.contentView.alpha = 0.0;
		} completion:^(BOOL finished) {
			updateViewState();
			[self.contentView setNeedsLayout];
			[self.contentView layoutIfNeeded];
			[UIView animateWithDuration:0.25 animations:^(void) {
				self.contentView.alpha = 1.0;
			}];
		}];
	}
	else {
		updateViewState();
		[self.contentView setNeedsLayout];
	}
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - [ Private Methods ]

- (void)updateTitle
{
	_titleLabel.text = [self.dataSource headingTextForMainDisplayController:self];
}

- (void)updateSubtitle
{
	//NMAmount *amount = [self.dataSource fundsDifferenceForMainDisplayController:self];
	NMAmount *amount = [self.dataSource bankAccountDifferenceForMainDisplayController:self];
	
	if (0.0 <= amount.value) {
		_subtitleLabel.textColor = [UIColor colorWithRGB:0xe7f820];
		_subtitleLabel.text = @"You're up";
	}
	else {
		_subtitleLabel.textColor = [UIColor colorWithRGB:0xff6600];
		_subtitleLabel.text = @"You're down";
	}
}

- (void)updateAmount
{
	//NMAmount *amount = [self.dataSource fundsDifferenceForMainDisplayController:self];
	NMAmount *amount = [self.dataSource bankAccountDifferenceForMainDisplayController:self];

	if (0.0 <= amount.value) {
		_amountLabel.textColor = [UIColor colorWithRGB:0xe7f820];
	}
	else {
		_amountLabel.textColor = [UIColor colorWithRGB:0xff6600];
	}

	_amountLabel.text = [NSString stringForAmountValue:fabs(amount.value) withCurrencyCode:amount.currencyCode];
}

- (void)updateComment
{
	_commentLabel.text = [self.dataSource commentTextForMainDisplayController:self];
}

- (void)updateBankAccountBalance // Currently hidden; soon to be obsoleted.
{
	NMAmount *amount = [self.dataSource bankAccountBalanceForMainDisplayController:self];

	_bankAccountBalanceLabel.text = [NSString stringForAmount:amount];
}

- (void)updateFundsBalance
{
	//NMAmount *amount = [self.dataSource fundsBalanceForMainDisplayController:self];
    NMAmount *amount = [self.dataSource bankAccountBalanceForMainDisplayController:self];
    
	_fundsBalanceLabel.text = [NSString stringForAmount:amount];
}

@end
