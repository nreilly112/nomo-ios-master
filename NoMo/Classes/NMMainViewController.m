//
//  NMMainViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMMainViewController.h"
#import "NMMainDisplayController.h"
#import "NMDemonstrationViewController.h"
#import "NMUserFinancialStatementModel.h"
#import "NMUserFinancialStatementItem.h"
#import "NMSummaryMessagesModel.h"
#import "NMVerificationIndicatorView.h"
#import "NMPageView.h"
#import "NMTaskScheduler.h"
#import "NMSession.h"
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>

#define kDemonstrateSummaryViewKey @"demonstrateSummaryView"
#define kDemonstrateDetailsViewKey @"demonstrateDetailsView"


@interface NMMainViewController () <NMPageViewDelegate, NMModelDelegate, NMMainDisplayControllerDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *watermarkImageView;
@property (nonatomic, weak) IBOutlet UIView *indicatorView;
@property (nonatomic, weak) IBOutlet NMPageView *pageView;
@property (nonatomic, weak) IBOutlet UILabel *lastUpdatedLabel;

@property (nonatomic, weak) IBOutlet UIView *swipeLeftView;
@property (nonatomic, weak) IBOutlet UIView *swipeRightView;

@property (nonatomic, strong) NMUserFinancialStatementModel *demonstrationModel;
@property (nonatomic, strong) NMUserFinancialStatementModel *model;

@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, assign) BOOL demonstrating;

@property (nonatomic, weak) NMUserFinancialStatementModel *viewModel;
@property (nonatomic, copy) NSString *headingText;
@property (nonatomic, copy) NSString *commentText;

- (IBAction)dismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)updateSettingsAndDismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)demonstrateSummaryAndDismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)demonstrateDetailsAndDismissModalViewController:(UIStoryboardSegue *)segue;

- (void)updateViewStateAnimated:(BOOL)animated;
- (void)updateStateAnimated:(BOOL)animated;
- (void)demonstrateIfNeeded;

@end


@implementation NMMainViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	NoMoContext *context = [NoMoContext sharedContext];
	[context removeObserver:self forKeyPath:@"currencyCode" context:NULL];
	[context removeObserver:self forKeyPath:@"applicationPersona" context:NULL];

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

	NoMoContext *context = [NoMoContext sharedContext];
	[context addObserver:self forKeyPath:@"currencyCode" options:NSKeyValueObservingOptionNew context:NULL];
	[context addObserver:self forKeyPath:@"applicationPersona" options:NSKeyValueObservingOptionNew context:NULL];
	
	NMSession *session = [NMSession sharedSession];
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	self.demonstrationModel = [NMUserFinancialStatementModel demonstrationModel];
	
	self.model = [NMUserFinancialStatementModel sharedModel];
	[self.model addDelegate:self];
	
	void (^refreshData)(void) = ^(void) {
		if (session.isOpen && !self.demonstrating) {
			[self.model load];
		}
	};
	void (^refreshState)(void) = ^(void) {
		if (self.isViewLoaded) {
			[self updateStateAnimated:YES];
		}
	};
	void (^resetState)(void) = ^(void) {
		self.pageView.currentPage = 0;
		
		[self.model invalidate];

		[self updateViewStateAnimated:NO];
		[self demonstrateIfNeeded];
	};
	
	_tasks = @[[scheduler addTaskWithBlock:resetState triggers:NMTaskTriggerSessionDidOpen],
			   [scheduler addTaskWithBlock:refreshState triggers:NMTaskTriggerSessionDidVerify],
			   [scheduler addTaskWithBlock:refreshData triggers:NMTaskTriggerSessionDidVerify],
			   [scheduler addTaskWithBlock:refreshData triggers:NMTaskTriggerApplicationDidBecomeActive],
			   [scheduler addTaskWithBlock:refreshData triggers:NMTaskTriggerNetworkAvailable],
			   [scheduler addPeriodicTaskWithBlock:refreshData interval:(15.0 * 60.0) delay:0.0]];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSLog(@"[Main] [viewDidLoad]");
	UIImage *image = [UIImage imageNamed:@"watermark"];
	UIColor *color = [UIColor colorWithPatternImage:image];
	
	_watermarkImageView.backgroundColor = color;
	
	[self updateViewStateAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"[Main] [View will appear]");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	NSLog(@"[Main] [View did appear]");
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	NSLog(@"[Main] [View will disappear]");
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	NSLog(@"[Main] [View did disappear]");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass:[NMMainDisplayController class]]) {
		NMMainDisplayController *displayController = segue.destinationViewController;
		displayController.dataSource = self;
	}
	else if ([segue.destinationViewController isKindOfClass:[NMDemonstrationViewController class]]) {
		_demonstrating = YES;
		[self updateViewStateAnimated:YES];
	}
}

#pragma mark - [ Actions ]

- (void)dismissModalViewController:(UIStoryboardSegue *)segue
{
	[self updateStateAnimated:NO];
}

- (void)updateSettingsAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	[_model cancelLoad];
	[_model load];
}

- (void)demonstrateSummaryAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	[[NoMoContext sharedContext] didPerformActionNamed:kActionDemonstrateSummary];
	self.swipeLeftView.hidden = NO;

	[segue notifyWhenTransitionCompletesUsingBlock:^(void) {
		self.demonstrating = NO;
		
		if (self.model.isLoaded) {
			[self updateViewStateAnimated:YES];
		}
		else {
			[self updateStateAnimated:YES];
		}
	}];
}

- (void)demonstrateDetailsAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	[[NoMoContext sharedContext] didPerformActionNamed:kActionDemonstrateDetails];
	self.swipeRightView.hidden = NO;

	[segue notifyWhenTransitionCompletesUsingBlock:^(void) {
		self.demonstrating = NO;

		if (self.model.isLoaded) {
			[self updateViewStateAnimated:YES];
		}
		else {
			[self updateStateAnimated:YES];
		}
	}];
}

- (void)closeDemoAndDismissModalViewController:(UIStoryboardSegue *)segue
{
    [[NoMoContext sharedContext] didPerformActionNamed:kActionDemonstrateDetails];
    [[NoMoContext sharedContext] didPerformActionNamed:kActionDemonstrateSummary];

    [segue notifyWhenTransitionCompletesUsingBlock:^(void) {
        self.demonstrating = NO;

        if (self.model.isLoaded) {
            [self updateViewStateAnimated:YES];
        }
        else {
            [self updateStateAnimated:YES];
        }
    }];
}

- (IBAction)reportButtonTapped:(UIButton *)sender {
    
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *lastUpdated = [_viewModel.issueDate stringWithFormat:@"HH:mm dd/MM/yy"];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *sessionId = [NMSession sharedSession].sessionId;
    NSString *device = [self deviceName];
    
    NSString *basicSubject = [NSString stringWithFormat:@"NoMo Money V%@ (Last updated: %@) %@", buildVersion, lastUpdated, @"%@"];
    NSString *basicMessageBody = [NSString stringWithFormat:@"Your feedback: \n\n\n\n\n\n Please do not remove the info below this line \n\n -----------------\n\n Last updated: %@ \n Type: %@ \n Model: %@ \n Version: iOS V%@ - NoMo Money V%@ \n DirectID UID: %@",
                             lastUpdated, @"%@", device, systemVersion, buildVersion, sessionId];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"I have a suggestion" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *subject = [NSString stringWithFormat:basicSubject, @"Suggestion"];
        NSString *message = [NSString stringWithFormat:basicMessageBody, @"Suggestion"];
        
        if (![MFMailComposeViewController canSendMail]) {
            [self openMailWithSubject:subject message:message];
            return;
        }
        [self openMailComposerWithSubject:subject message:message];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"I want to raise an issue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *subject = [NSString stringWithFormat:basicSubject, @"Issue"];
        NSString *message = [NSString stringWithFormat:basicMessageBody, @"Issue"];
        
        if (![MFMailComposeViewController canSendMail]) {
            [self openMailWithSubject:subject message:message];
            return;
        }
        [self openMailComposerWithSubject:subject message:message];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Nothing to be done.
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - [ NSKeyValueObserving ]

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)ctx
{
	NoMoContext *context = [NoMoContext sharedContext];
	
	if ((object == context) && ([keyPath isEqualToString:@"currencyCode"])) {
		[self.model cancelLoad];
		[self.model load];
	}
	else if ((object == context) && ([keyPath isEqualToString:@"applicationPersona"])) {
		[self updateViewStateAnimated:NO];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:ctx];
	}
}

#pragma mark - [ NMPageViewDelegate ]

- (void)pageViewDidStartScrolling:(NMPageView *)pageView
{
	if (!self.swipeLeftView.hidden) {
		[self.swipeLeftView setHidden:YES animated:YES];
	}
	if (!self.swipeRightView.hidden) {
		[self.swipeRightView setHidden:YES animated:YES];
	}
}

- (void)pageView:(NMPageView *)pageView didScrollToPageAtIndex:(NSUInteger)index
{
	[self demonstrateIfNeeded];
}

#pragma mark - [ NMModelDelegate Methods ]

- (void)modelDidStartLoad:(id<NMModel>)model
{
	[self updateStateAnimated:YES];
}

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	[self updateStateAnimated:YES];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	NSLog(@"[Main] [Failed to complete load operation (Error: %@)]", error.description);
	
	[self updateStateAnimated:YES];
}

- (void)modelDidCancelLoad:(id<NMModel>)model
{
	[self updateStateAnimated:YES];
}

- (void)modelDidChange:(id<NMModel>)model
{
	[self updateViewStateAnimated:YES];
}

#pragma mark - [ MFMailComposeViewController Methods ]

-(void)openMailComposerWithSubject:(NSString *)subject message:(NSString *)message{
    
    MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
    composeVC.mailComposeDelegate = self;
    
    [composeVC setToRecipients:@[@"support@nomo.money"]];
    [composeVC setSubject:subject];
    [composeVC setMessageBody:message isHTML:NO];
    
    [self presentViewController:composeVC animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - [ NMMainDisplayControllerDataSource ]

- (NSDate *)issueDateForMainDisplayController:(NMMainDisplayController *)viewController
{
	return _viewModel.issueDate;
}

- (NMAmount *)bankAccountBalanceForMainDisplayController:(NMMainDisplayController *)viewController
{
	return [_viewModel balanceOfAssetNamed:kAssetNameBankAccount onDate:_viewModel.issueDate];
}

- (NMAmount *)bankAccountHistoricAverageForMainDisplayController:(NMMainDisplayController *)viewController
{
	return [_viewModel historicAverageOfAssetNamed:kAssetNameBankAccount onDate:_viewModel.issueDate];
}

- (NMAmount *)bankAccountAvailableBalanceForMainDisplayController:(NMMainDisplayController *)viewController
{
    return [_viewModel availableBalanceOfAssetNamed:kAssetNameBankAccount onDate:_viewModel.issueDate];
}

- (NMAmount *)bankAccountOverdraftForMainDisplayController:(NMMainDisplayController *)viewController
{
    return [_viewModel overdraftOfAssetNamed:kAssetNameBankAccount onDate:_viewModel.issueDate];
}

- (NMAmount *)bankAccountTotalBalanceForMainDisplayController:(NMMainDisplayController *)viewController
{
    return [_viewModel totalBalanceOfAssetNamed:kAssetNameBankAccount onDate:_viewModel.issueDate];
}

- (NMAmount *)bankAccountDifferenceForMainDisplayController:(NMMainDisplayController *)viewController
{
	NMAmount *balance = [self bankAccountBalanceForMainDisplayController:nil];
	NMAmount *historicAverage = [self bankAccountHistoricAverageForMainDisplayController:nil];
	
	return [balance subtractAmount:historicAverage];
}

- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController bankAccountBalanceForDate:(NSDate *)date
{
	return [_viewModel balanceOfAssetNamed:kAssetNameBankAccount onDate:date];
}

- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController bankAccountHistoricAverageForDate:(NSDate *)date
{
	return [_viewModel historicAverageOfAssetNamed:kAssetNameBankAccount onDate:date];
}

- (NMAmount *)fundsBalanceForMainDisplayController:(NMMainDisplayController *)viewController
{
	return [_viewModel balanceOfAssetNamed:kAssetNameFunds onDate:_viewModel.issueDate];
}

- (NMAmount *)fundsHistoricAverageForMainDisplayController:(NMMainDisplayController *)viewController
{
	return [_viewModel historicAverageOfAssetNamed:kAssetNameFunds onDate:_viewModel.issueDate];
}

- (NMAmount *)fundsDifferenceForMainDisplayController:(NMMainDisplayController *)viewController
{
	NMAmount *balance = [self fundsBalanceForMainDisplayController:nil];
	NMAmount *historicAverage = [self fundsHistoricAverageForMainDisplayController:nil];
	
	return [balance subtractAmount:historicAverage];
}

- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController fundsBalanceForDate:(NSDate *)date
{
	return [_viewModel balanceOfAssetNamed:kAssetNameFunds onDate:date];
}

- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController fundsHistoricAverageForDate:(NSDate *)date
{
	return [_viewModel historicAverageOfAssetNamed:kAssetNameFunds onDate:date];
}

- (NSString *)headingTextForMainDisplayController:(NMMainDisplayController *)viewController
{
	return _headingText;
}

- (NSString *)commentTextForMainDisplayController:(NMMainDisplayController *)viewController
{
	return _commentText;
}

#pragma mark - [ Private Methods ]

- (void)updateViewStateAnimated:(BOOL)animated
{
	_viewModel = _model;
	
	if (_demonstrating || !_model.isLoaded) {
		_viewModel = _demonstrationModel;
	}
	
	if (_viewModel.isLoaded) {
		NMApplicationPersona effectivePersona = [NoMoContext sharedContext].applicationPersona;
		NMAmount *fundsDifference = [self bankAccountDifferenceForMainDisplayController:nil];
		
		_headingText = [[NMSummaryMessagesModel summaryHeadingsModel] textWithPersona:effectivePersona forAmount:fundsDifference];
		_commentText = [[NMSummaryMessagesModel summaryCommentsModel] textWithPersona:effectivePersona forAmount:fundsDifference];

		NSString *lastUpdatedDate = [_viewModel.issueDate stringWithFormat:@"HH:mm dd/MM/yy"];
		NSString *lastUpdatedText = [NSString stringWithFormat:@"Last updated %@", lastUpdatedDate];
		
		[_lastUpdatedLabel setHidden:YES animated:animated completion:^(BOOL finished) {
			self.lastUpdatedLabel.text = lastUpdatedText;
			[self.lastUpdatedLabel setHidden:NO animated:animated];
		}];
		
		for (id viewController in self.childViewControllers) {
			if ([viewController isKindOfClass:[NMMainDisplayController class]]) {
				NMMainDisplayController *displayController = viewController;
				[displayController reloadDataAnimated:animated];
			}
		}
	}
	else {
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Still updating"];
		[_lastUpdatedLabel setHidden:YES animated:animated];
	}
	
	[self updateStateAnimated:animated];
}

- (void)updateStateAnimated:(BOOL)animated
{
	
	BOOL shouldIndicatorBeVisible = _demonstrating || _model.isLoading;
	[_indicatorView setHidden:!shouldIndicatorBeVisible animated:animated];

	BOOL shouldWatermarkBeVisible = _demonstrating || !_model.isLoaded;
	[_watermarkImageView setHidden:!shouldWatermarkBeVisible animated:animated];
}

- (void)demonstrateIfNeeded
{
	if (!_demonstrating) {
		NoMoContext *context = [NoMoContext sharedContext];
		
		if (_pageView.currentPage == 0) {
			if (![context hasPerformedActionNamed:kActionDemonstrateSummary]) {
				[_indicatorView setHidden:NO animated:YES];
				[_lastUpdatedLabel setHidden:NO animated:YES];
				[self performSegueWithIdentifier:@"DemonstrateSummary" sender:self];
			}
		}
		else if (_pageView.currentPage == 1) {
			if (![context hasPerformedActionNamed:kActionDemonstrateDetails]) {
				[self performSegueWithIdentifier:@"DemonstrateDetails" sender:self];
			}
		}
	}
}

- (NSString *)deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(void)openMailWithSubject:(NSString *)subject message:(NSString *)message
{
    NSString *url = [NSString stringWithFormat:@"mailto:support@nomo.money?subject=%@&body=%@", subject, message];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url] options:@{} completionHandler:nil];
}

@end
