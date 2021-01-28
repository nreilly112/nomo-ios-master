//
//  NMAuthenticationController.m
//  NoMo
//
//  Created by Costas Harizakis on 10/18/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAuthenticationController.h"
#import "NMAuthenticationWidgetViewController.h"
#import "NoMoUserSessionTokenModel.h"
#import "DirectIDSettings.h"
#import "NMSession.h"


@interface NMAuthenticationController () <NMModelDelegate, NMAuthenticationWidgetViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *completedView;

@property (nonatomic, strong) NoMoUserSessionTokenModel *tokenModel;
@property (nonatomic, weak) NMAuthenticationWidgetViewController *widgetController;

- (IBAction)didTapRetryButton:(id)sender;
- (IBAction)didTapCanelButton:(id)sender;

- (void)showLoadingView:(BOOL)show animated:(BOOL)animated;
- (void)showCompletedView:(BOOL)show animated:(BOOL)animated;

@end


@implementation NMAuthenticationController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_widgetController cancelLoad];
	
	[_tokenModel removeDelegate:self];
	[_tokenModel invalidate];
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];

	NMSession *session = [NMSession sharedSession];
	NMIdentity *userIdentity = session.userIdentity;
 
	if (userIdentity == nil) {
		NSString *grantType = [NoMoSettings grantType];
        NSString *clientId = [NoMoSettings clientId];
        NSString *clientSecret = [NoMoSettings clientSecret];
        NSString *scope = [NoMoSettings scope];
		
        userIdentity = [NMIdentity identityWithGrantType:grantType clientId:clientId clientSecret:clientSecret scope:scope];
	}

	_tokenModel = [[NoMoUserSessionTokenModel alloc] initForUserWithIdentity:userIdentity];
	[_tokenModel addDelegate:self];
}

#pragma mark - [ UIViewController ]

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[_loadingView setHidden:YES];
	[_completedView setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"[Authentication] [View will appear] [Self: %p]", self);
	
	if (_tokenModel.isLoading) {
		[self showLoadingView:YES animated:NO];
	}
	else if (!_tokenModel.isLoaded) {
		[_tokenModel load];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSLog(@"[Authentication] [View did appear]");
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSLog(@"[Authentication] [View will disappear]");
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	NSLog(@"[Authentication] [View did disappear]");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass:[NMAuthenticationWidgetViewController class]]) {
		_widgetController = segue.destinationViewController;
		_widgetController.delegate = self;
	}
}

#pragma mark - [ Events ]

- (void)didComplete
{
	if ([_delegate respondsToSelector:@selector(authenticationControllerDidComplete:)]) {
		[_delegate authenticationControllerDidComplete:self];
	}
}

- (void)didCancel
{
	if ([_delegate respondsToSelector:@selector(authenticationControllerDidCancel:)]) {
		[_delegate authenticationControllerDidCancel:self];
	}
}

- (void)didFailWithError:(NSError *)error
{
	if ([_delegate respondsToSelector:@selector(authenticationController:didFailWithError:)]) {
		[_delegate authenticationController:self didFailWithError:error];
	}
}

#pragma mark - [ Actions ]

- (void)didTapRetryButton:(id)sender
{
	// NOTE: Not currently used.
	[_widgetController cancelLoad];
	[_tokenModel invalidate];
	[_tokenModel load];
}

- (void)didTapCanelButton:(id)sender
{
	[_widgetController cancelLoad];
	[_tokenModel cancelLoad];
	
	[self didCancel];
}

#pragma mark - [ NMModelDelegate Members ]

- (void)modelDidStartLoad:(id<NMModel>)model
{
	[self showLoadingView:YES animated:NO];
}

- (void)modelDidFinishLoad:(id<NMModel>)model
{
    [_widgetController loadWithWidgetUrl:_tokenModel.widgetUrl];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	[self showLoadingView:NO animated:YES];
	[self didFailWithError:error];
}

#pragma mark - [ NMLoginWidgetViewControllerDelegate ]

- (void)authenticationWidgetViewControllerDidInitialize:(NMAuthenticationWidgetViewController *)viewController
{
	[self showLoadingView:NO animated:YES];
}

- (void)authenticationWidgetViewControllerDidComplete:(NMAuthenticationWidgetViewController *)viewController
{
    [[UIApplication sharedApplication] setWarningAlertWasDisplayed:NO];
    
	NMSession *session = [NMSession sharedSession];
	NSDictionary *parameters = @{ kNMSessionParameterNumberOfLoginAttempts: @(_widgetController.numberOfLoginAttempts),
								  kNMSessionParameterNumberOfFailedLoginAttempts: @(_widgetController.numberOfFailedLoginAttempts) };
	
    [session openForUserWithIdentity:_tokenModel.userIdentity sessionId:_tokenModel.sessionId
						  parameters:parameters];
	
	[self showCompletedView:YES animated:YES];
	[self performBlockOnMainThread:^(void) { [self didComplete]; } afterDelay:2.0];
}

- (void)authenticationWidgetViewController:(NMAuthenticationWidgetViewController *)viewController didFailWithError:(NSError *)error
{
	[self showLoadingView:NO animated:YES];
	[self didFailWithError:error];
}

#pragma mark - [ Private Methods ]

- (void)showLoadingView:(BOOL)show animated:(BOOL)animated
{
	[_loadingView setHidden:!show animated:animated];
}

- (void)showCompletedView:(BOOL)show animated:(BOOL)animated
{
	[_completedView setHidden:!show animated:animated];
}

@end
