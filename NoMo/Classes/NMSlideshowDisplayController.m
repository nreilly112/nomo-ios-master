//
//  NMSlideshowDisplayController.m
//  NoMo
//
//  Created by Costas Harizakis on 9/24/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSlideshowDisplayController.h"
#import "NMSlideshowView.h"
#import "NMImageListModel.h"
#import "NMTaskScheduler.h"
#import "NMSession.h"


@interface NMSlideshowDisplayController () <NMModelDelegate>

@property (nonatomic, weak) IBOutlet NMSlideshowView *slideshowView;
@property (nonatomic, weak) IBOutlet UIView *loadingView;

@property (nonatomic, strong) NMImageListModel *model;
@property (nonatomic, strong) NSArray *tasks;

- (void)showLoading:(BOOL)show animated:(BOOL)animated;
- (void)updateViewState;
- (void)updateState;

@end


@implementation NMSlideshowDisplayController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_model removeDelegate:self];
	_model = nil;
	
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_model = [NMImageListModel welcomeImagesModel];
	[_model addDelegate:self];
	
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	void (^resetState)(void) = ^(void) {
		self.slideshowView.currentSlide = 0;
	};
	
	_tasks = @[[scheduler addTaskWithBlock:resetState triggers:NMTaskTriggerSessionDidClose]];
}

#pragma mark - [ UIViewController Methods ]

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateState];
}

#pragma mark - [ NMModelDelegate ]

- (void)modelDidStartLoad:(id<NMModel>)model
{
	[self updateState];
}

- (void)modelDidFinishLoad:(id<NMModel>)model
{
	[self updateViewState];
}

- (void)modelDidCancelLoad:(id<NMModel>)model
{
	[self updateState];
}

- (void)model:(id<NMModel>)model didFailLoadWithError:(NSError *)error
{
	[self updateViewState];
}

#pragma mark - [ Private Methods ]

- (void)showLoading:(BOOL)show animated:(BOOL)animated
{
	[_loadingView setHidden:!show animated:animated];
}

- (void)updateViewState
{
	_slideshowView.slideImagePaths = _model.items;
	[self updateState];
}

- (void)updateState
{
	[self showLoading:_model.isLoading animated:YES];
}

@end

