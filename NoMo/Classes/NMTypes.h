//
//  NMTypes.h
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//


typedef NS_ENUM(NSInteger, NMWeekday)  {
	NMWeekdayDefault = 0,
	NMWeekdaySunday = 1,
	NMWeekdayMonday = 2,
	NMWeekdayTuesday = 3,
	NMWeekdayWednesday = 4,
	NMWeekdayThursday = 5,
	NMWeekdayFriday = 6,
	NMWeekdaySaturday = 7
};

typedef NS_ENUM(NSInteger, NMButtonState) {
	NMButtonStateDefault = 0,
	NMButtonStateEnabled = (1 << 0),
	NMButtonStateSelected = (1 << 1)
};

typedef NS_ENUM(NSInteger, NMSessionVerificationState) {
	NMSessionVerificationStateUnknown = 0,
	NMSessionVerificationStateApproved = 1,
	NMSessionVerificationStateRejected = 2,
	NMSessionVerificationStateSuspended = 3
};

extern NMSessionVerificationState NMSessionVerificationStateFromErrorCode(NSInteger errorCode);

typedef NS_ENUM(NSInteger, NMApplicationPersona) {
	NMApplicationPersonaDefault = 0,
	NMApplicationPersonaFun = 1,
	NMApplicationPersonaMoreFun = 2
};
