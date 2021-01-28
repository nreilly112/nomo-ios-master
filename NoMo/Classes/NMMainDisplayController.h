//
//  NMMainDisplayController.h
//  NoMo
//
//  Created by Costas Harizakis on 01/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@class NMMainDisplayController;

@protocol NMMainDisplayControllerDataSource <NSObject>

- (NSDate *)issueDateForMainDisplayController:(NMMainDisplayController *)viewController;

- (NMAmount *)bankAccountBalanceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)bankAccountHistoricAverageForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)bankAccountDifferenceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)bankAccountAvailableBalanceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)bankAccountOverdraftForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)bankAccountTotalBalanceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController bankAccountBalanceForDate:(NSDate *)date;
- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController bankAccountHistoricAverageForDate:(NSDate *)date;

- (NMAmount *)fundsBalanceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)fundsHistoricAverageForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)fundsDifferenceForMainDisplayController:(NMMainDisplayController *)viewController;
- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController fundsBalanceForDate:(NSDate *)date;
- (NMAmount *)mainDisplayController:(NMMainDisplayController *)viewController fundsHistoricAverageForDate:(NSDate *)date;

- (NSString *)headingTextForMainDisplayController:(NMMainDisplayController *)viewController;
- (NSString *)commentTextForMainDisplayController:(NMMainDisplayController *)viewController;

@end


@interface NMMainDisplayController : UIViewController

@property (nonatomic, weak) id<NMMainDisplayControllerDataSource> dataSource;

- (void)reloadDataAnimated:(BOOL)animated;

@end
