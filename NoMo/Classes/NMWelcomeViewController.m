//
//  NMWelcomeViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMWelcomeViewController.h"
#import "NMAuthenticationController.h"
#import "NMSession.h"


@interface NMWelcomeViewController () <NMAuthenticationControllerDelegate>

- (IBAction)dismissModalViewController:(UIStoryboardSegue *)segue;
- (IBAction)didTapLoginButton:(id)sender;

@end


@implementation NMWelcomeViewController

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSLog(@"[Welcome] [View will appear]");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	NSLog(@"[Welcome] [View did appear]");
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	NSLog(@"[Welcome] [View will disappear]");
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	NSLog(@"[Welcome] [View did disappear]");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Login"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		NMAuthenticationController *viewController = (NMAuthenticationController *)navigationController.topViewController;
		viewController.delegate = self;
	}
}

#pragma mark - [ Actions ]

- (void)dismissModalViewController:(UIStoryboardSegue *)segue
{
	// NOTE: Default dismiss.
}

- (void)didTapLoginButton:(id)sender
{
#if 1
	[self performSegueWithIdentifier:@"Login" sender:self];
#else
	// NOTE: The followinf is used for debugging purposes, bypassing the login flow.
	NMSession *session = [NMSession sharedSession];
	NMIdentity *identity = [NMIdentity identityWithName:@"defaultuser" domain:@"nomo-dev"];
	NSString *reference = @"82074eb414c14e7d9156fba8e0c26ea4";
	NSDictionary *parameters = @{ kNMSessionParameterVerificationState: @(NMSessionVerificationStateApproved) };
	[session openForUserWithIdentity:identity reference:reference parameters:parameters];
#endif
}

#pragma mark - [ NMAuthenticationControllerDelegate ]

- (void)authenticationControllerDidComplete:(NMAuthenticationController *)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticationControllerDidCancel:(NMAuthenticationController *)viewController
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticationController:(NMAuthenticationController *)viewController didFailWithError:(NSError *)error
{
	// NOTE: Shall we notify the user?
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
