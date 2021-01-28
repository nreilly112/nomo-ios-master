//
//  NMWelcomeInterfaceController.m
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMWelcomeInterfaceController.h"
#import "NMExtensionModel.h"


@interface NMWelcomeInterfaceController () <NMModelDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *contentGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *loadingGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *amountLabel;

@property (nonatomic, strong) NMExtensionModel *model;

- (void)updateState;

@end


@implementation NMWelcomeInterfaceController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_model removeDelegate:self];
}

#pragma mark - [ Initializer ]

- (void)awakeWithContext:(id)context
{
	[super awakeWithContext:context];
	
	_model = [NMExtensionModel sharedModel];
	[_model addDelegate:self];
}

#pragma mark - [ WKInterfaceController ]

- (void)willActivate
{
	[super willActivate];
	[self updateState];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

#pragma mark - [ NMModelDelegate ]

- (void)modelDidChange:(id<NMModel>)model
{
	[self updateState];
}

#pragma mark - [ Private Methods ]

- (void)updateState
{
	if (_model.isLoaded) {
		[_contentGroup setHidden:NO];
		[_loadingGroup setHidden:YES];
		
		NMAmount *amount = [_model.fundsBalance subtractAmount:_model.fundsHistoricAverage];
		NSString *amountString = [NSString stringForAmount:[amount absoluteAmount]];

		if (0.0 <= amount.value) {
			[_subtitleLabel setText:@"You're up"];
			[_subtitleLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
			[_amountLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
		}
		else {
			[_subtitleLabel setText:@"You're down"];
			[_subtitleLabel setTextColor:[UIColor colorWithRGB:0xff6600]];
			[_amountLabel setTextColor:[UIColor colorWithRGB:0xff6600]];
		}
		
		[_titleLabel setText:_model.heading];
		[_amountLabel setText:amountString];
	}
	else {
		[_contentGroup setHidden:YES];
		[_loadingGroup setHidden:NO];
	}
}

@end



