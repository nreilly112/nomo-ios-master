//
//  NMMainDetailsDisplayController.m
//  NoMo
//
//  Created by Costas Harizakis on 10/27/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMMainDetailsDisplayController.h"
#import "NMFinancialGraphView.h"
#import "NMUserSettingsModel.h"


@interface NMMainDetailsDisplayController () <NMFinacialGraphViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *indicatorImageView;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UILabel *fundsBalanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *fundsAverageLabel;
@property (nonatomic, weak) IBOutlet UILabel *bankAccountBalanceLabel;
@property (nonatomic, weak) IBOutlet NMFinancialGraphView *financialGraphView;
@property (weak, nonatomic) IBOutlet UILabel *availableBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *overdraftLabel;
@property (weak, nonatomic) IBOutlet UIView *overdraftGroupView;

@end


@implementation NMMainDetailsDisplayController

#pragma mark - [ NMMainDisplayController Methods ]

- (void)reloadDataAnimated:(BOOL)animated
{
	[super reloadDataAnimated:animated];
	
	void (^updateViewState)(void) = ^(void) {
		[self updateTitle];
		[self updateIndicatorImage];
		[self updateAmount];
		[self updateFundsBalance];
		[self updateFundsHistoricAverage];
		[self updateBankAccountBalance];
        [self updateOverdraftGroup];
		[self updateGraph];
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
		[_contentView setNeedsLayout];
	}
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - [ NMFinacialGraphViewDataSource ]

- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView balanceForDate:(NSDate *)date
{
	//return [self.dataSource mainDisplayController:self fundsBalanceForDate:date];
	return [self.dataSource mainDisplayController:self bankAccountBalanceForDate:date];
}

- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView historicAverageForDate:(NSDate *)date
{
	//return [self.dataSource mainDisplayController:self fundsHistoricAverageForDate:date];
	return [self.dataSource mainDisplayController:self bankAccountHistoricAverageForDate:date];
}

#pragma mark - [ Private Methods ]

- (void)updateTitle
{
	//NMAmount *amount = [self.dataSource fundsDifferenceForMainDisplayController:self];
	NMAmount *amount = [self.dataSource bankAccountDifferenceForMainDisplayController:self];

	if (0.0 <= amount.value) {
		_titleLabel.textColor = [UIColor colorWithRGB:0xe7f820];
		_titleLabel.text = @"You're up";
	}
	else {
		_titleLabel.textColor = [UIColor colorWithRGB:0xff6600];
		_titleLabel.text = @"You're down";
	}
}

- (void)updateIndicatorImage
{
	//NMAmount *amount = [self.dataSource fundsDifferenceForMainDisplayController:self];
	NMAmount *amount = [self.dataSource bankAccountDifferenceForMainDisplayController:self];

	if (0.0 < amount.value) {
		[_indicatorImageView setImageNamed:@"trend-indicator-up"];
	}
	else if (amount.value < 0.0) {
		[_indicatorImageView setImageNamed:@"trend-indicator-down"];
	}
	else {
		[_indicatorImageView setImageNamed:@"trend-indicator-same"];
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

- (void)updateFundsBalance
{
	//NMAmount *difference = [self.dataSource fundsDifferenceForMainDisplayController:self];
	//NMAmount *amount = [self.dataSource fundsBalanceForMainDisplayController:self];
	NMAmount *difference = [self.dataSource bankAccountDifferenceForMainDisplayController:self];
    NMAmount *amount = [self.dataSource bankAccountBalanceForMainDisplayController:self];

	if (0.0 <= difference.value) {
		_fundsBalanceLabel.textColor = [UIColor colorWithRGB:0xe7f820];
        _overdraftLabel.textColor = [UIColor colorWithRGB:0xe7f820];
        _availableBalanceLabel.textColor= [UIColor colorWithRGB:0xe7f820];
	}
	else {
		_fundsBalanceLabel.textColor = [UIColor colorWithRGB:0xff6600];
        _overdraftLabel.textColor = [UIColor colorWithRGB:0xff6600];
        _availableBalanceLabel.textColor= [UIColor colorWithRGB:0xff6600];
	}

	_fundsBalanceLabel.text = [NSString stringForAmount:amount];
}

- (void)updateFundsHistoricAverage
{
	//NMAmount *amount = [self.dataSource fundsHistoricAverageForMainDisplayController:self];
	NMAmount *amount = [self.dataSource bankAccountHistoricAverageForMainDisplayController:self];

	_fundsAverageLabel.text = [NSString stringForAmount:amount];
}

- (void)updateBankAccountBalance // Currently hidden; soon to be obsoleted.
{
	NMAmount *amount = [self.dataSource bankAccountBalanceForMainDisplayController:self];

	_bankAccountBalanceLabel.text = [NSString stringForAmount:amount];
}

- (void)updateAvailableBalance
{
    NMAmount *amount = [self.dataSource bankAccountAvailableBalanceForMainDisplayController:self];
    
    _availableBalanceLabel.text = [NSString stringForAmount:amount];
}

- (void)updateOverdraft
{
    NMAmount *amount = [self.dataSource bankAccountOverdraftForMainDisplayController:self];
    
    if (amount.value == 0) {
        _overdraftLabel.text = @"None";
        return;
    }
    _overdraftLabel.text = [NSString stringForAmount:amount];
}

-(void)updateOverdraftGroup
{
    NMUserSettingsModel *settings = [NMUserSettingsModel sharedModel];
    if (!settings.includeOverdraft) {
        [_overdraftGroupView setHidden:YES];
        return;
    }
    [_overdraftGroupView setHidden:NO];
    [self updateAvailableBalance];
    [self updateOverdraft];
}

- (void)updateGraph
{
	NSDate *date = [[self.dataSource issueDateForMainDisplayController:self] startOfDay];
	//NMAmount *amount = [self.dataSource mainDisplayController:self fundsBalanceForDate:date];
	NMAmount *amount = [self.dataSource mainDisplayController:self bankAccountBalanceForDate:date];
	NSString *caption = [NSString stringWithFormat:@"%@ %ld", [date monthString], (long)date.year];
	
	_financialGraphView.currencyCode = amount.currencyCode;
	_financialGraphView.earliestDate = [date startOfMonth];
	_financialGraphView.latestDate = [[date endOfMonth] dateByAddingDays:-1];
	_financialGraphView.caption = caption;
	[_financialGraphView reloadData];
}

@end
