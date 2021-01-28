//
//  NMTypes.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMTypes.h"


NMSessionVerificationState NMSessionVerificationStateFromErrorCode(NSInteger errorCode)
{
	switch (errorCode) {
		case 0:
			return NMSessionVerificationStateApproved;
		case 417:
			return NMSessionVerificationStateSuspended;
		default:
			return NMSessionVerificationStateRejected;
	}
	
	return NMSessionVerificationStateUnknown;
}
