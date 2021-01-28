//
//  NMCurrencyPickerController.m
//  NoMo
//
//  Created by Costas Harizakis on 17/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMCurrencyPickerController.h"


@interface NMCurrencyPickerController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) NSArray *items;

- (NSString *)titleForCurrencyCode:(NSString *)currencyCode;

@end


@implementation NMCurrencyPickerController

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_items = @[ @"GBP",
				@"USD",
				@"EUR",
				@"CAD",
				@"ILS",
				@"AED",
				@"ZAR",
				@"INR",
				@"THB",
				@"SGD",
				@"HKD",
				@"AUD",
				@"NZD" ];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSInteger index = [_items indexOfObject:_selectedCurrencyCode];
	
	if (index != NSNotFound) {
		[_pickerView selectRow:index inComponent:0 animated:NO];
		_submitButton.enabled = NO;
	}
}

#pragma mark - [ UIPickerViewDelegate ]

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *currencyCode = [_items objectAtIndex:row];
	NSString *title = [self titleForCurrencyCode:currencyCode];
	
	return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	_selectedCurrencyCode = [_items objectAtIndex:row];
	_submitButton.enabled = YES;
}

#pragma mark - [ UIPickerViewDataSource ]

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return _items.count;
}

#pragma mark - [ Private Methods ]

- (NSString *)titleForCurrencyCode:(NSString *)currencyCode
{
	static NSDictionary *titles = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		titles = @{ @"GBP": @"British Pound",
					@"USD": @"US Dollar",
					@"EUR": @"Euro",
					@"CAD": @"Canadian Dollar",
					@"ILS": @"Israeli Shekel",
					@"AED": @"Emirati Dirham",
					@"ZAR": @"South African Rand",
					@"INR": @"Indian Rupee",
					@"THB": @"Thai Baht",
					@"SGD": @"Singapore Dollar",
					@"HKD": @"Hong Kong Dollar",
					@"AUD": @"Australian Dollar",
					@"NZD": @"New Zealand Dollar" };
	});
	
	NSString *title = [titles objectOrNilForKey:currencyCode];
	
	if (title == nil) {
		return currencyCode;
	}

	return [NSString stringWithFormat:@"%@ (%@)", currencyCode, title];
}

@end
