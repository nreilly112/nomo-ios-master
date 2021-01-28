//
//  DirectIDIndividualDetailsModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMIndividualDetailsItem.h"


@interface DirectIDIndividualDetailsModel : NMModel

@property (nonatomic, copy, readonly) NSString *reference;

- (instancetype)initWithReference:(NSString *)reference;

- (BOOL)load;
- (void)cancelLoad;
- (void)invalidate;

@end
