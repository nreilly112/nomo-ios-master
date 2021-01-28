//
//  NMMainExtensionDisplayController.m
//  NoMo
//
//  Created by Costas Harizakis on 22/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMMainExtensionDisplayController.h"
#import "NMFinancialGraphView.h"
#import "NMExtensionModel.h"
#import "NMTaskScheduler.h"
#import "NMSession.h"


@interface NMMainExtensionDisplayController () <NMModelDelegate, NMFinacialGraphViewDataSource>

@property (nonatomic, strong) IBOutlet NMFinancialGraphView *graphView;
@property (nonatomic, strong) NMExtensionModel *model;
@property (nonatomic, strong) NSArray *tasks;

@end


@implementation NMMainExtensionDisplayController

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[_model removeDelegate:self];
	
	for (id<NMTask> task in _tasks) {
		[task cancel];
	}
}

#pragma mark - [ Initializer ]

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	NMTaskScheduler *scheduler = [NMTaskScheduler defaultScheduler];
	
	self.model = [NMExtensionModel sharedModel];
	[_model addDelegate:self];
	
	self.tasks = @[[scheduler addTaskWithBlock:^(void) { [self.model invalidate]; } triggers:NMTaskTriggerSessionDidClose],
			   [scheduler addTaskWithBlock:^(void) { [self reloadDataAnimated:NO]; } triggers:NMTaskTriggerSessionDidVerify]];
}

#pragma mark - [ NMMainDisplayController Methods ]

- (void)reloadDataAnimated:(BOOL)animated
{
	[super reloadDataAnimated:animated];
	
	NSDate *issueDate = [self.dataSource issueDateForMainDisplayController:self];
	NSString *heading = [self.dataSource headingTextForMainDisplayController:self];
	NSString *comment = [self.dataSource commentTextForMainDisplayController:self];
	//NMAmount *fundsBalance = [self.dataSource fundsBalanceForMainDisplayController:self];
	//NMAmount *fundsHistoricAverage = [self.dataSource fundsHistoricAverageForMainDisplayController:self];
	NMAmount *fundsBalance = [self.dataSource bankAccountBalanceForMainDisplayController:self];
	NMAmount *fundsHistoricAverage = [self.dataSource bankAccountHistoricAverageForMainDisplayController:self];
	
	self.graphView.currencyCode = fundsBalance.currencyCode;
	self.graphView.earliestDate = [issueDate dateByAddingDays:-1];
	self.graphView.latestDate = [issueDate dateByAddingDays:1];
	self.graphView.caption = nil;
	[self.graphView reloadData];
	[self.graphView setNeedsLayout];
	[self.graphView layoutIfNeeded];
	
	UIImage *graphImage = [_graphView snapshotImage];
	
    [self.model beginUpdates];
    
    self.model.date = issueDate;
    self.model.heading = heading;
    self.model.comment = comment;
    self.model.fundsBalance = fundsBalance;
    self.model.fundsHistoricAverage = fundsHistoricAverage;
    self.model.fundsGraph = graphImage;
    
    [self.model endUpdates];
    [self.model save];
}

#pragma mark - [ NMFinacialGraphViewDataSource Members ]

- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView balanceForDate:(NSDate *)date
{
	//return [self.dataSource mainDisplayController:self fundsBalanceForDate:date];
	return [self.dataSource mainDisplayController:self bankAccountBalanceForDate:date];
}

- (NMAmount *)financialGraphView:(NMFinancialGraphView *)graphView historicAverageForDate:(NSDate *)date
{
	//return [self.dataSource mainDisplayController:self fundsHistoricAverageForDate:date];
	return [self.dataSource mainDisplayController:self bankAccountHistoricAverageForDate:date];
}

@end
