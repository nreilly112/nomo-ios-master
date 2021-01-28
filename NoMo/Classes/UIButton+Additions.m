//
//  UIButton+Additions.m
//  NoMo
//
//  Created by Costas Harizakis on 9/23/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "UIButton+Additions.h"


@implementation UIButton (Additions)

- (NMButtonState)buttonState
{
	NMButtonState state = NMButtonStateDefault;
	state |= (self.enabled) ? NMButtonStateEnabled : NMButtonStateDefault;
	state |= (self.selected) ? NMButtonStateSelected : NMButtonStateDefault;
	
	return state;
}

- (void)setButtonState:(NMButtonState)state
{
	self.enabled = (state & NMButtonStateEnabled);
	self.selected = (state & NMButtonStateSelected);
}

@end
