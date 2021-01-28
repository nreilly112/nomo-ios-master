//
//  NMDetailsInterfaceController.m
//  NoMo
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMDetailsInterfaceController.h"
#import "NMExtensionModel.h"


@interface NMDetailsInterfaceController () <NMModelDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *contentGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *loadingGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *balanceLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *historicAverageLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *graphImage;

@property (nonatomic, strong) NMExtensionModel *model;

@end


@implementation NMDetailsInterfaceController

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

		NMAmount *difference = [_model.fundsBalance subtractAmount:_model.fundsHistoricAverage];
		NSString *balanceString = [NSString stringForAmount:_model.fundsBalance];
		NSString *historicAverageString = [NSString stringForAmount:_model.fundsHistoricAverage];

		if (0 <= difference.value) {
			[_balanceLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
		}
		else {
			[_balanceLabel setTextColor:[UIColor colorWithRGB:0xe7f820]];
		}
		
		[_balanceLabel setText:balanceString];
		[_historicAverageLabel setText:historicAverageString];
		[_graphImage setImage:_model.fundsGraph];
	}
	else {
		[_contentGroup setHidden:YES];
		[_loadingGroup setHidden:NO];
	}
}

@end



