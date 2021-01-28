//
//  DirectIDIndividualsListModel.h
//  NoMo
//
//  Created by Costas Harizakis on 9/29/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMModel.h"
#import "NMIndividualItem.h"


@interface DirectIDIndividualsListModel : NMModel <NMListModel>

@property (nonatomic, strong, readonly) NSArray *items; // Array of NMIndividualItem objects.
@property (nonatomic, assign, readonly) NSUInteger count;

- (id)itemAtIndex:(NSUInteger)index;

- (BOOL)load;
- (void)cancelLoad;
- (void)invalidate;

@end
