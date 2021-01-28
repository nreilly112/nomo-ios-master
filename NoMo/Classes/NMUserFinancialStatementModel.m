//
//  NMUserFinancialStatementModel.m
//  NoMo
//
//  Created by Costas Harizakis on 10/20/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMUserFinancialStatementModel.h"
#import "NMUserFinancialStatementItem.h"
#import "NMDevice.h"


@interface NMUserFinancialStatementModel ()

@property (nonatomic, copy) NMUserFinancialStatementItem *item;
@property (nonatomic, strong) NSURLSessionDataTask *loadTask;
@property (nonatomic, copy) NSString *stateKey;
@property (nonatomic, assign) int refreshedRequestCount;

- (instancetype)initWithSession:(id<NMSession>)session;

- (void)updateStateKey;
- (void)restoreState;
- (void)saveState;

- (NSString *)temporaryPathWithIdentifier:(NSString *)identifier;

@end


@implementation NMUserFinancialStatementModel

#pragma mark - [ Finalizer ]

- (void)dealloc
{
	[self invalidate];
}

#pragma mark - [ Initializers ]

- (instancetype)_init
{
	return [self initWithSession:nil];
}

- (instancetype)initWithSession:(id<NMSession>)session
{
	self = [super initWithSession:session];
	
	if (self) {
		_item = nil;
		_loadTask = nil;
        
        self.refreshedRequestCount = 0;
		
		[self updateStateKey];
		[self restoreState];
	}
	
	return self;
}

#pragma mark - [ Methods ]

- (NSDate *)issueDate
{
	return _item.issueDate;
}

- (NSArray *)assetNames
{
	return [_item assetNames];
}

- (NSDate *)earliestDateForBalanceOfAssetNamed:(NSString *)assetName
{
	NSDate *date = nil;
	NSArray *items = [_item allDataForAssetNamed:assetName];
	
	for (NMAssetDataItem *item in items) {
		if (!isnan(item.balance)) {
			date = [date earlierDate:item.date] ?: item.date;
		}
	}
	
	return [date startOfDay];
}

- (NSDate *)latestDateForBalanceOfAssetNamed:(NSString *)assetName
{
	NSDate *date = nil;
	NSArray *items = [_item allDataForAssetNamed:assetName];
	
	for (NMAssetDataItem *item in items) {
		if (!isnan(item.balance)) {
			date = [date laterDate:item.date] ?: item.date;
		}
	}
	
	return [date startOfDay];
}

- (NSDate *)earliestDateForHistoricAverageOfAssetNamed:(NSString *)assetName
{
	NSDate *date = nil;
	NSArray *items = [_item allDataForAssetNamed:assetName];
	
	for (NMAssetDataItem *item in items) {
		if (!isnan(item.historicAverage)) {
			date = [date earlierDate:item.date] ?: item.date;
		}
	}
	
	return [date startOfDay];
	
}

- (NSDate *)latestDateForHistoricAverageOfAssetNamed:(NSString *)assetName
{
	NSDate *date = nil;
	NSArray *items = [_item allDataForAssetNamed:assetName];
	
	for (NMAssetDataItem *item in items) {
		if (!isnan(item.historicAverage)) {
			date = [date laterDate:item.date] ?: item.date;
		}
	}
	
	return [date startOfDay];
}

- (NMAmount *)balanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
	NMAssetDataItem *assetData = [_item dataForAssetNamed:assetName onDate:date];
	
	if (assetData && !isnan(assetData.balance)) {
		return [NMAmount amountWithValue:assetData.balance currencyCode:_item.currency];
	}
	
	return nil;
}

- (NMAmount *)historicAverageOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
	NMAssetDataItem *assetData = [_item dataForAssetNamed:assetName onDate:date];
	
	if (assetData && !isnan(assetData.historicAverage)) {
		return [NMAmount amountWithValue:assetData.historicAverage currencyCode:_item.currency];
	}
	
	return nil;
}

- (NMAmount *)overdraftOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
    NMAssetDataItem *assetData = [_item dataForAssetNamed:assetName onDate:date];
    
    if (assetData && !isnan(assetData.overdraft)) {
        return [NMAmount amountWithValue:assetData.overdraft currencyCode:_item.currency];
    }
    
    return nil;
}

- (NMAmount *)availableBalanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
    NMAssetDataItem *assetData = [_item dataForAssetNamed:assetName onDate:date];
    
    if (assetData && !isnan(assetData.availableBalance)) {
        return [NMAmount amountWithValue:assetData.availableBalance currencyCode:_item.currency];
    }
    
    return nil;
}

- (NMAmount *)totalBalanceOfAssetNamed:(NSString *)assetName onDate:(NSDate *)date
{
    NMAssetDataItem *assetData = [_item dataForAssetNamed:assetName onDate:date];
    
    if (assetData && !isnan(assetData.totalBalance)) {
        return [NMAmount amountWithValue:assetData.totalBalance currencyCode:_item.currency];
    }
    
    return nil;
}


#pragma mark - [ NoMoModel Protected Methods ]

- (void)sessionDidOpen
{
	[self updateStateKey];
	[self restoreState];
}

#pragma mark - [ NMModel Methods ]

- (void)invalidate
{
	[super invalidate];

	_item = nil;
	
	[self saveState];
}

#pragma mark - [ NoMoLoadModel Members ]

- (NSURLSessionDataTask *)loadTaskWithSessionManager:(NoMoHTTPSessionManager *)manager
{
    if (!self.session.isOpen) {
		return nil;
	}
	
	NMJSONObjectCompletionHandler completionHandler = ^(NSURLSessionDataTask *task, NSDictionary *properties, NSError *error) {
		if (self.loadTask == task) {
			self.loadTask = nil;
			
			if (error) {
				[self didFailLoadWithError:error];
			}
			else {
                @try {

                    int bankDataResponseCode = [[properties valueForKey:@"bankDataResponseCode"] intValue];
                    
                    //403 - the consent or account access has been revoked
                    if (bankDataResponseCode == 403) {
                        // logout
                        [[NMSession sharedSession] close];
                        return;
                    }
                    //404 - no account or consent_id
                    if (bankDataResponseCode == 404 && self.refreshedRequestCount < 3) {
                        // try to refresh 3 times - this may take some time until backend receives the consent id
                        double delayInSeconds = 120.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self loadTaskWithSessionManager:[NoMoHTTPSessionManager defaultManager]];
                            self.refreshedRequestCount++;
                        });
                        return;
                    }
                }
                @catch (NSException *exception) {
                    
                }
                
				self.item = [[NMUserFinancialStatementItem alloc] initWithProperties:properties];
                
                [self saveRecognizedCurrency:[[properties objectOrNilForKey:@"currency"] copy]];
                    
				[self saveState];
				
				[self setModified:NO];
				[self didFinishLoad];
				[self didChange];
			}
		}
	};
	
	_loadTask = [manager getFinancialStatementForUserWithIdentity:self.session.userIdentity
												completionHandler:completionHandler];
	
	if (_loadTask) {
		[self didStartLoad];
	}
	
	return _loadTask;
}

- (void)didCancelLoadTask:(NSURLSessionDataTask *)task
{
	if (_loadTask == task) {
		_loadTask = nil;
		[self didCancelLoad];
	}
}

#pragma mark - [ Private Methods ]

- (void)restoreState
{
	if (_stateKey) {
		NSString *path = [self temporaryPathWithIdentifier:_stateKey];
		NSString *password = [self encryptionPassword];
		NSDictionary *properties = [NSDictionary dictionaryWithContentsOfEncryptedFile:path password:password];
		
		if (properties.count == 0) {
			properties = nil;
		}
		
		NSLog(@"[UserFinancialStatementModel] [Restoring state (Path: \"%@\")]", path);
		
		_item = [properties itemOfKind:[NMUserFinancialStatementItem class]];
		
		if (_item) {
			[self setLoaded:YES];
			[self didChange];
		}
	}
}

- (void)saveState
{
	if (_stateKey) {
		NSString *path = [self temporaryPathWithIdentifier:_stateKey];
		NSString *password = [self encryptionPassword];
		
		if (_item) {
			NSLog(@"[UserFinancialStatementModel] [Saving state (Path: \"%@\")]", path);
			[_item.properties writeToEncryptedFile:path password:password atomically:YES];
		}
		else {
			NSLog(@"[UserFinancialStatementModel] [Clearing state (Path: \"%@\")]", path);
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		}
	}
}

- (void)updateStateKey
{
	if (self.session.isOpen) {
        _stateKey = self.session.sessionId;
	}
}

- (NSString *)temporaryPathWithIdentifier:(NSString *)identifier
{
	NSString *file = [NSString stringWithFormat:@"user_financial_statement_%@.plist", identifier ?: @"default" ];
	NSString *path = [file stringByPrependingDefaultCacheDirectory];
	
	return path;
}

- (NSString *)encryptionPassword
{
	return [NMDevice uniqueIdentifier];
}

- (BOOL)saveRecognizedCurrency:(NSString *)currency {
    NSUserDefaults *recognizedCurrency = [NSUserDefaults standardUserDefaults];
    [recognizedCurrency setObject:currency forKey:@"recognizedCurrency"];
    return [recognizedCurrency synchronize];
}

#pragma mark - [ Static Methods ]

+ (instancetype)sharedModel
{
	static NMUserFinancialStatementModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NMSession *session = [NMSession sharedSession];
		instance = [[NMUserFinancialStatementModel alloc] initWithSession:session];
		instance.authenticationEnabled = YES;
	});
	
	return instance;
}

@end


@implementation NMUserFinancialStatementModel (Demonstration)

- (BOOL)loadDemonstrationData
{
	NSString *file = @"model-financial_statement.json";
	NSString *path = [file stringByPrependingMainBundleResourcePath];
	NSDictionary *properties = [NSDictionary dictionaryWithJSONContentsOfFile:path];
	
	if (properties) {
		_item = [[NMUserFinancialStatementItem alloc] initWithProperties:properties];
		[self setLoaded:YES];
	}
	
	return self.isLoaded;
}

+ (instancetype)demonstrationModel
{
	static NMUserFinancialStatementModel *instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[NMUserFinancialStatementModel alloc] init];
		[instance loadDemonstrationData];
	});
	
	return instance;
}

@end
