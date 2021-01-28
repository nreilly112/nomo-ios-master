//
//  NMActivityIndicatorView.m
//  NoMo
//
//  Created by Costas Harizakis on 10/17/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMActivityIndicatorView.h"
#import "NMTaskScheduler.h"


@interface NMActivityIndicatorView () <CALayerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *indicatorView;
@property (nonnull, strong) id<NMTask> restartAnimationTask;

- (void)updateState;

@end


@implementation NMActivityIndicatorView

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_restartAnimationTask cancel];
	_restartAnimationTask = nil;
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self addContentSubview:[self contentViewFromNib]];
	[self updateState];
	
	_restartAnimationTask = [[NMTaskScheduler defaultScheduler] addTaskWithBlock:^(void) { [self updateState]; } triggers:NMTaskTriggerApplicationWillEnterForeground];
}

- (void)setAnimating:(BOOL)animating
{
	if (_animating != animating) {
		_animating = animating;
		[self updateState];
	}
}

- (void)startAnimating
{
	if (!_animating) {
		_animating = YES;
		[self updateState];
	}
}

- (void)stopAnimating
{
	if (_animating) {
		_animating = NO;
		[self updateState];
	}
}

#pragma mark - [ UIView Methods ]

- (void)didMoveToWindow
{
	[super didMoveToWindow];
	[self updateState];
}

#pragma mark - [ Private Methods ]

- (void)updateState
{
	if (_animating) {
		CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
		rotation.fromValue = [NSNumber numberWithFloat:0];
		rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
		rotation.duration = 1.0;
		rotation.speed = 1.0f;
		rotation.repeatCount = MAXFLOAT;
		
		_indicatorView.layer.timeOffset = 0.0; // [_indicatorView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
		_indicatorView.layer.beginTime = 0.0;
		
		[_indicatorView.layer addAnimation:rotation forKey:@"rotate"];

		self.hidden = NO;
	}
	else {
		[_indicatorView.layer removeAnimationForKey:@"rotate"];
		
		self.hidden = _hidesWhenStopped;
	}
}

@end
