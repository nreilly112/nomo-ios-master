//
//  NMSettingsViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/26/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSettingsViewController.h"
#import "NMUserSettingsModel.h"
#import "NMUserSettingsViewModel.h"
#import "NMNotificationThresholdsModel.h"
#import "NMDemonstrationViewController.h"
#import "NMCurrencyPickerController.h"
#import "NMSession.h"
#import "NMTaskScheduler.h"


@interface NMSettingsViewController () <NMModelDelegate>

@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UILabel *currencyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *incrementNotificationValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *incrementNotificationMinValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *incrementNotificationMaxValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *decrementNotificationValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *decrementNotificationMinValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *decrementNotificationMaxValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *applicationPersonaValueLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *dismissBarButtonItem;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *savingView;
@property (nonatomic, weak) IBOutlet NMUserSettingsViewModel *viewModel;

@property (nonatomic, strong) NMUserSettingsModel *model;
@property (nonatomic, assign) double minimumAllowedValue;
@property (nonatomic, assign) double maximumAllowedValue;
@property (nonatomic, assign) double stepForAllowedValue;
@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, assign) BOOL demonstrating;

- (IBAction)dismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)updateViewModelAndDismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)demonstrateSettingsAndDismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)didTapLogoutButton:(id)sender;
- (IBAction)didTapSubmitButton:(id)sender;

- (void)showLoading:(BOOL)show animated:(BOOL)animated;
- (void)showSaving:(BOOL)show animated:(BOOL)animated;
- (void)updateViewModel;
- (void)updateModel;
- (void)updateState;
- (void)demonstrateIfNeeded;

- (NSString *)amountTextForValue:(CGFloat)value currencyCode:(NSString *)currencyCode;
- (NSString *)applicationPersonaTextForValue:(NSUInteger)value;
- (NSString *)notificationsTextForValue:(BOOL)value;
- (CGFloat)fractionForValue:(CGFloat)value;
- (CGFloat)valueForFraction:(CGFloat)fraction;
- (double)stepForValuesInRange:(double)range;

@end


@implementation NMSettingsViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
	
	[_model removeDelegate:self];
	[_model invalidate];
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	_model = [NMUserSettingsModel sharedModel];
	[_model addDelegate:self];
	
	void (^loadModelIfNeeded)(void) = ^(void) {
		if (!self.model.isLoaded) {
			[self.model cancelLoad];
			[self.model load];
		}
	};
	
	_tasks = @[[scheduler addTaskWithBlock:loadModelIfNeeded triggers:NMTaskTriggerNetworkAvailable]];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (!_model.isLoaded) {
		[_model load];
	}

	[self updateViewModel];
	[self updateState];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass:[NMDemonstrationViewController class]]) {
		_demonstrating = YES;
	}
	else if ([segue.destinationViewController isKindOfClass:[NMCurrencyPickerController class]]) {
		NMCurrencyPickerController *currencyPicker = segue.destinationViewController;
		currencyPicker.selectedCurrencyCode = _viewModel.preferredCurrencyCode;
	}
}

#pragma mark - [ NMModelDelegate (Load) ]

- (void)modelDidStartLoad:(id<NMModel>)model
{
	[self updateState];
}

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	[self updateViewModel];
	[self updateState];
	[self demonstrateIfNeeded];
}

- (void)modelDidCancelLoad:(id<NMModel>)model
{
	[self updateState];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	NSLog(@"[Settings] [Failed to complete load operation (Error: %@)]", error.description);
}

#pragma mark - [ SSEModelDelegate (Save) ]

- (void)modelDidStartSave:(id<NMModel>)model
{
	[self updateState];
}

- (void)modelDidFinishSave:(id<NMModel>)model
{
	[_viewModel clearModified];
	[self updateState];	
	[self performSegueWithIdentifier:@"Update" sender:nil];
}

- (void)modelDidCancelSave:(id<NMModel>)model
{
	[self updateState];
}

- (void)model:(id<NMModel>)model didFailSaveWithError:(NSError *)error
{
	NSLog(@"[Settings] [Failed to complete save operation (Error: %@)]", error.description);

	[self updateState];
}

#pragma mark - [ NMViewModelDelegate Methods ]

- (void)viewModelDidChange:(id<NMViewModel>)viewModel
{
	[self updateState];
}

#pragma mark - [ Actions ]

- (void)dismissModalViewController:(UIStoryboardSegue *)segue
{
	[self updateState];
}

- (void)updateViewModelAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	if ([segue.sourceViewController isKindOfClass:[NMCurrencyPickerController class]]) {
		NMCurrencyPickerController *currencyPicker = segue.sourceViewController;
		NSString *preferredCurrencyCode = currencyPicker.selectedCurrencyCode;
		
		_viewModel.preferredCurrencyCode = preferredCurrencyCode;
		_minimumAllowedValue = [[NMNotificationThresholdsModel defaultModel] minimumAllowedValueForCurrencyCode:preferredCurrencyCode];
		_maximumAllowedValue = [[NMNotificationThresholdsModel defaultModel] maximumAllowedValueForCurrencyCode:preferredCurrencyCode];
		_stepForAllowedValue = [self stepForValuesInRange:(_maximumAllowedValue - _minimumAllowedValue)];
		
		[self updateState];
	}
}

- (void)demonstrateSettingsAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	[[NoMoContext sharedContext] didPerformActionNamed:kActionDemonstrateSettings];
	[self updateState];

	[segue notifyWhenTransitionCompletesUsingBlock:^(void) {
		self.demonstrating = NO;
	}];
}

- (void)didTapLogoutButton:(id)sender
{
	[self.view endEditing:NO];
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Disconnect my bank account"
																   message:@"NoMo will still have access to your bank until the consented period expires. You will need to revoke NoMo's access at your bank's own online platform to fully disconnect your bank account from NoMo (The entity will be displayed as DirectID or The ID Co. at your bank)."
															preferredStyle:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes, I'm sure" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self performSegueWithIdentifier:@"Dismiss" sender:nil];
		[[NMSession sharedSession] close];
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No, cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		// Nothing to be done.
	}]];
	
	UIPopoverPresentationController *presentationController = alert.popoverPresentationController;
	presentationController.sourceView = self.view;
	presentationController.sourceRect = [_logoutButton convertRect:_logoutButton.bounds toView:self.view];
	presentationController.canOverlapSourceViewRect = NO;
	presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)didTapSubmitButton:(id)sender
{
	[self.view endEditing:NO];
	[self updateModel];
	[_model save];
}

#pragma mark - [ Private Methods ]

- (void)showLoading:(BOOL)show animated:(BOOL)animated
{
	[_loadingView setHidden:!show animated:animated];
}

- (void)showSaving:(BOOL)show animated:(BOOL)animated
{
	[_savingView setHidden:!show animated:animated];
}

- (void)updateViewModel
{
	if (_model.isLoaded) {
		NoMoContext *context = [NoMoContext sharedContext];
		UIApplication *application = [UIApplication sharedApplication];

		NSString *preferredCurrencyCode = _model.preferredCurrencyCode ?: context.currencyCode;

		_minimumAllowedValue = [[NMNotificationThresholdsModel defaultModel] minimumAllowedValueForCurrencyCode:preferredCurrencyCode];
		_maximumAllowedValue = [[NMNotificationThresholdsModel defaultModel] maximumAllowedValueForCurrencyCode:preferredCurrencyCode];
		_stepForAllowedValue = [self stepForValuesInRange:(_maximumAllowedValue - _minimumAllowedValue)];
		
		[_viewModel beginUpdates];
		_viewModel.preferredCurrencyCode = preferredCurrencyCode;
		_viewModel.incrementNotificationThreshold = [self fractionForValue:_model.incrementNotificationThreshold];
		_viewModel.decrementNotificationThreshold = [self fractionForValue:_model.decrementNotificationThreshold];
		_viewModel.applicationPersona = _model.applicationPersona;
		_viewModel.notificationsEnabled = _model.notificationsEnabled;
        _viewModel.includeOverdraft = _model.includeOverdraft;
		
		if (application.notificationsAuthorizationStatus != UNAuthorizationStatusAuthorized) {
			_viewModel.notificationsEnabled = NO;
		}
		
		[_viewModel endUpdates];
		[_viewModel clearModified];
	}
}

- (void)updateModel
{
	if (_viewModel.isValid) {
		[_model beginUpdates];
		_model.preferredCurrencyCode = _viewModel.preferredCurrencyCode;
		_model.incrementNotificationThreshold = [self valueForFraction:_viewModel.incrementNotificationThreshold];
		_model.decrementNotificationThreshold = [self valueForFraction:_viewModel.decrementNotificationThreshold];
		_model.applicationPersona = _viewModel.applicationPersona;
		_model.notificationsEnabled = _viewModel.notificationsEnabled;
        _model.includeOverdraft = _viewModel.includeOverdraft;
		[_model endUpdates];
	}
}

- (void)updateState
{
	self.navigationController.navigationItem.backBarButtonItem.enabled = !_model.isSaving;
	_dismissBarButtonItem.enabled = !_model.isSaving;
	_cancelButton.enabled = !_model.isSaving;
	_submitButton.enabled = _viewModel.isValid && _viewModel.isModified && !_model.isLoading && !_model.isSaving;
	
	_currencyValueLabel.text = _viewModel.preferredCurrencyCode ?: @"(default)";
	_incrementNotificationValueLabel.text = [self amountTextForValue:[self valueForFraction:_viewModel.incrementNotificationThreshold] currencyCode:_viewModel.preferredCurrencyCode];
	_incrementNotificationMinValueLabel.text = [self amountTextForValue:_minimumAllowedValue currencyCode:nil];
	_incrementNotificationMaxValueLabel.text = [self amountTextForValue:_maximumAllowedValue currencyCode:nil];
	_decrementNotificationValueLabel.text = [self amountTextForValue:[self valueForFraction:_viewModel.decrementNotificationThreshold] currencyCode:_viewModel.preferredCurrencyCode];
	_decrementNotificationMinValueLabel.text = [self amountTextForValue:_minimumAllowedValue currencyCode:nil];
	_decrementNotificationMaxValueLabel.text = [self amountTextForValue:_maximumAllowedValue currencyCode:nil];
	_applicationPersonaValueLabel.text = [self applicationPersonaTextForValue:_viewModel.applicationPersona];
	
	[self showLoading:_model.isLoading animated:YES];
	[self showSaving:_model.isSaving animated:YES];
}

- (void)demonstrateIfNeeded
{
	if (!_demonstrating) {
		if (![[NoMoContext sharedContext] hasPerformedActionNamed:kActionDemonstrateSettings]) {
			[self performSegueWithIdentifier:@"DemonstrateSettings" sender:self];
		}
	}
}

#pragma mark - [ Private Methods (Helpers) ]

- (NSString *)amountTextForValue:(CGFloat)value currencyCode:(NSString *)currencyCode
{
	NSNumber *number = [NSNumber numberWithDouble:value];
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	if (currencyCode) {
		[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[currencyFormatter setCurrencyCode:_viewModel.preferredCurrencyCode];
	}
	
	if (value < 1000.0) {
		[currencyFormatter setMaximumFractionDigits:0];
		[currencyFormatter setPositiveSuffix:@""];
		[currencyFormatter setMultiplier:@(1.0)];
	}
	else if (value < 1000000.0) {
		[currencyFormatter setAlwaysShowsDecimalSeparator:NO];
		[currencyFormatter setMinimumFractionDigits:0];
		[currencyFormatter setMaximumFractionDigits:2];
		[currencyFormatter setPositiveSuffix:@"K"];
		[currencyFormatter setMultiplier:@(0.001)];
	}
	else if (value < 1000000000.0) {
		[currencyFormatter setMinimumFractionDigits:1];
		[currencyFormatter setMaximumFractionDigits:1];
		[currencyFormatter setPositiveSuffix:@"M"];
		[currencyFormatter setMultiplier:@(0.000001)];
	}
	else {
		[currencyFormatter setMinimumFractionDigits:1];
		[currencyFormatter setMaximumFractionDigits:1];
		[currencyFormatter setPositiveSuffix:@"B"];
		[currencyFormatter setMultiplier:@(0.000000001)];
	}
	
	return [currencyFormatter stringFromNumber:number];
}

- (NSString *)applicationPersonaTextForValue:(NSUInteger)value
{
	switch (value) {
		case 0:
			return @"Friendly";
		case 1:
			return @"Cheeky";
		case 2:
			return @"Motivating";
		default:
			break;
	}

	return @"(n/a)";
}

- (CGFloat)fractionForValue:(CGFloat)value
{
	CGFloat fraction = 0.0;
	
	if (_minimumAllowedValue != _maximumAllowedValue) {
		fraction = (value - _minimumAllowedValue) / (_maximumAllowedValue - _minimumAllowedValue);
	}
	
	return MIN(MAX(0.0, fraction), 1.0);
}

- (CGFloat)valueForFraction:(CGFloat)fraction
{
	CGFloat value = 0.0;
	
	if (_minimumAllowedValue != _maximumAllowedValue) {
		if (fraction == 1.0) {
			value = _maximumAllowedValue;
		}
		else if (fraction == 0.0) {
			value = _minimumAllowedValue;
		}
		else {
			value = fraction * (_maximumAllowedValue - _minimumAllowedValue);
			value = floor(value / _stepForAllowedValue) * _stepForAllowedValue;
			value = _minimumAllowedValue + value;
		}
		
	}
	
	return MIN(MAX(_minimumAllowedValue, value), _maximumAllowedValue);
}

- (double)stepForValuesInRange:(double)range
{
	double value = range / 40.0;
	double exponent = floor(log10(value));
	double roundedValue = pow(10.0, exponent);
	double fraction = value / roundedValue;
	
	if (fraction < 1.5) {
		fraction = 1.0;
	}
	else if (fraction < 3.0) {
		fraction = 2.0;
	}
	else if (fraction < 7.5) {
		fraction = 5.0;
	}
	else {
		fraction = 10.0;
	}
	
	return fraction * roundedValue;
}

@end
