//
//  NMRootViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 14/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMRootViewController.h"
#import "NMTaskScheduler.h"


@interface NMRootViewController ()

@property (nonatomic, weak) IBOutlet UIView *snapshotPreventionView;
@property (nonatomic, weak) IBOutlet UIView *launchScreenView;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;

@property (nonatomic, strong) NSArray *tasks;

- (IBAction)acceptTermsAndDismissModalViewController:(UIStoryboardSegue *)segue;

- (void)networkDidBecomeAvailable;
- (void)networkDidBecomeUnavailable;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;

- (void)showMessage:(BOOL)show animated:(BOOL)animated;
- (void)updateStateAnimated:(BOOL)animated;

@end


@implementation NMRootViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];

	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	_tasks = @[[scheduler addTaskWithBlock:^(void) { [self networkDidBecomeAvailable]; } triggers:NMTaskTriggerNetworkAvailable],
			   [scheduler addTaskWithBlock:^(void) { [self networkDidBecomeUnavailable]; } triggers:NMTaskTriggerNetworkUnavailable],
			   [scheduler addTaskWithBlock:^(void) { [self applicationDidEnterBackground]; } triggers:NMTaskTriggerApplicationDidEnterBackground],
			   [scheduler addTaskWithBlock:^(void) { [self applicationWillEnterForeground]; } triggers:NMTaskTriggerApplicationWillEnterForeground]];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	NoMoContext *context = [NoMoContext sharedContext];

	if (![context hasPerformedActionNamed:kActionAcceptTermsAndConditions]) {
		[self performSegueWithIdentifier:@"Terms" sender:self];
	}
	
	[self updateStateAnimated:YES];
}

#pragma mark - [ Actions ]

- (void)acceptTermsAndDismissModalViewController:(UIStoryboardSegue *)segue
{
	[[NoMoContext sharedContext] didPerformActionNamed:kActionAcceptTermsAndConditions];
	[self updateStateAnimated:NO];
}

- (void)networkDidBecomeAvailable
{
	_messageView.backgroundColor = [UIColor colorWithRGB:0x18a1db];
	_messageLabel.text = @"Network available";

	[self showMessage:NO animated:YES];
}

- (void)networkDidBecomeUnavailable
{
	_messageView.backgroundColor = [UIColor colorWithRGB:0xf87216];
	_messageLabel.text = @"Network not available";
	
	[self showMessage:YES animated:YES];
}

- (void)applicationDidEnterBackground
{
	[_snapshotPreventionView setHidden:NO];
}

- (void)applicationWillEnterForeground
{
	[_snapshotPreventionView setHidden:YES];
}

#pragma mark - [ Private Methods ]

- (void)showMessage:(BOOL)show animated:(BOOL)animated
{
	[_messageView setNeedsLayout];
	[_messageView layoutIfNeeded];

	_messageViewHeightConstraint.constant = (show) ? _messageLabel.height : 0.0;;
	[_messageView setNeedsUpdateConstraints];
	
	void (^animations)(void) = ^(void) {
		[self.view setNeedsLayout];		
		[self.view layoutIfNeeded];
	};
	
	if (animated) {
		[UIView animateWithDuration:0.25 animations:animations];
	}
	else {
		animations();
	}
}

- (void)updateStateAnimated:(BOOL)animated
{
	NoMoContext *context = [NoMoContext sharedContext];
	
	if ([context hasPerformedActionNamed:kActionAcceptTermsAndConditions]) {
		[_contentView setHidden:NO animated:animated];
		[_launchScreenView setHidden:YES animated:animated];
	}
}

@end


@implementation UIViewController (NMRootViewController)

- (NMRootViewController *)rootViewController
{
	if ([self isKindOfClass:[NMRootViewController class]]) {
		return (NMRootViewController *)self;
	}
	
	NMRootViewController *rootViewController = self.presentingViewController.rootViewController;
	
	if (rootViewController != nil) {
		return rootViewController;
	}
	
	return self.parentViewController.rootViewController;
}

@end
