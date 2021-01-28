//
//  NMRootContentViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMRootContentViewController.h"
#import "NMTaskScheduler.h"
#import "NMSession.h"


#define kTermsAndConditionsKey @"termsAndConditions"


@interface NMRootContentViewController ()

@property (nonatomic, copy) IBInspectable NSString *welcomeSegueIdentifier;
@property (nonatomic, copy) IBInspectable NSString *mainSegueIdentifier;

@property (nonatomic, weak) IBOutlet UIView *welcomeViewContainerView;
@property (nonatomic, weak) IBOutlet UIView *mainViewContainerView;

@property (nonatomic, weak) UIViewController *welcomeViewController;
@property (nonatomic, weak) UIViewController *mainViewController;

@property (nonatomic, strong) NSArray *tasks;

- (void)updateStateAnimated:(BOOL)animated;

@end


@implementation NMRootContentViewController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
}

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	void (^updateState)(void) = ^(void) {
		[self updateStateAnimated:YES];
	};
	
	_tasks = @[[scheduler addTaskWithBlock:updateState triggers:NMTaskTriggerSessionDidOpen],
			   [scheduler addTaskWithBlock:updateState triggers:NMTaskTriggerSessionDidClose]];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self updateStateAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:_welcomeSegueIdentifier]) {
		_welcomeViewController = segue.destinationViewController;
	}
	else if ([segue.identifier isEqualToString:_mainSegueIdentifier]) {
		_mainViewController = segue.destinationViewController;
	}
}

#pragma mark - [ Private Methods ]

- (void)updateStateAnimated:(BOOL)animated
{
	NMSession *session = [NMSession sharedSession];
	
	if (session.isOpen) {
		[_mainViewContainerView setHidden:NO animated:animated];
		[_welcomeViewContainerView setHidden:YES animated:animated];
	}
	else {
		[_mainViewContainerView setHidden:YES animated:animated];
		[_welcomeViewContainerView setHidden:NO animated:animated];
	}
}

@end


