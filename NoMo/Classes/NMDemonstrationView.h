//
//  NMDemonstrationView.h
//  NoMo
//
//  Created by Costas Harizakis on 15/11/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMAnnotatedView.h"


@interface NMDemonstrationView : UIView

@property (nonatomic, strong) NMAnnotatedView *annotatedView;

- (void)setAnnotatedView:(NMAnnotatedView *)annotatedView animated:(BOOL)animated;

@end
