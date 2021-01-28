//
//  NMDemonstrationViewController.m
//  NoMo
//
//  Created by Costas Harizakis on 15/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMDemonstrationViewController.h"
#import "NMDemonstrationView.h"


@interface NMDemonstrationViewController ()

@property (nonatomic, weak) IBOutlet NMDemonstrationView *annotationView;

@property (nonatomic, strong) NSMutableArray *annotatedViews;
@property (nonatomic, assign) NSInteger annotatedViewNextIndex;

- (IBAction)didTapBackgroundView:(UIGestureRecognizer *)recognizer;

- (void)initializeAnnotations;
- (BOOL)moveToNextAnnotation;

@end


@implementation NMDemonstrationViewController

#pragma mark - [ Initializers ]

- (void)awakeFromNib
{
	[super awakeFromNib];
}

#pragma mark - [ UIViewController ]

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self initializeAnnotations];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (![self moveToNextAnnotation]) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - [ Actions ]

- (void)didTapBackgroundView:(UIGestureRecognizer *)recognizer
{
	if (![self moveToNextAnnotation]) {
		[self performSegueWithIdentifier:@"Dismiss" sender:self];
	}
}

- (IBAction)closeButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"CloseDemo" sender:self];
}

#pragma mark - [ Private Methods ]

- (void)initializeAnnotations
{
	UIViewController *presentingController = self.presentingViewController;
	UIView *presentingView = presentingController.view;
	
	_annotatedViews = [[NSMutableArray alloc] init];
	_annotatedViewNextIndex = 0;
	
	for (NSInteger tag = _firstTag; tag < _lastTag; tag += 1) {
		UIView *annotatedView = [presentingView descendantOrSelfWithTag:tag];
		
		if ([annotatedView isKindOfClass:[NMAnnotatedView class]]) {
			[_annotatedViews addObject:annotatedView];
		}
	}
}

- (BOOL)moveToNextAnnotation
{
	while (_annotatedViewNextIndex < _annotatedViews.count) {
		NMAnnotatedView *view = [_annotatedViews objectAtIndex:_annotatedViewNextIndex++];
		
		if (view && !view.isHidden) {
			[_annotationView setAnnotatedView:view animated:YES];
			return YES;
		}
	}
	
	return NO;
}

@end

