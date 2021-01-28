//
//  NMNotificationController.m
//  Watch Extension
//
//  Created by Costas Harizakis on 21/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMNotificationController.h"


@interface NMNotificationController()

@end


@implementation NMNotificationController

- (instancetype)init
{
    self = [super init];

	if (self) {
		// Nothing to be done.
    }
	
	return self;
}

- (void)willActivate
{
    [super willActivate];
}

- (void)didDeactivate
{
    [super didDeactivate];
}

/*
- (void)didReceiveNotification:(UNNotification *)notification withCompletion:(void(^)(WKUserNotificationInterfaceType interface))completionHandler
 {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}
*/

@end



