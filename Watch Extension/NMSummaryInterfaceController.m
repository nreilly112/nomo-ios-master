//
//  NMSummaryInterfaceController.m
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMSummaryInterfaceController.h"
#import "NMExtensionModel.h"


@interface NMSummaryInterfaceController () <NMModelDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *contentGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *loadingGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *indicatorImage;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *amountLabel;

@property (nonatomic, strong) NMExtensionModel *model;

- (void)updateState;

@end


@implementation NMSummaryInterfaceController

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
		
		if (0.0 < amount.value) {
			[_indicatorImage setImageNamed:@"trend-indicator-up"];
			[_titleLabel setText:@"You're up"];
			[_titleLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
			[_amountLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
		}
		else if (amount.value < 0.0) {
			[_indicatorImage setImageNamed:@"trend-indicator-down"];
			[_titleLabel setText:@"You're down"];
			[_titleLabel setTextColor:[UIColor colorWithRGB:0xff6600]];
			[_amountLabel setTextColor:[UIColor colorWithRGB:0xff6600]];
		}
		else {
			[_indicatorImage setImageNamed:@"trend-indicator-same"];
			[_titleLabel setText:@"You're up"];
			[_titleLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
			[_amountLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
		}
		
		[_amountLabel setText:amountString];
	}
	else {
		[_contentGroup setHidden:YES];
		[_loadingGroup setHidden:NO];
	}
}

@end



