//
//  NMSecurityContext.h
//  NoMo
//
//  Created by Costas Harizakis on 9/30/16.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMToken.h"


extern NSString * const kNMSecurityContextDidChangeNotification;


@interface NMSecurityContext : NSObject

@property (nonatomic, strong) id<NMToken> accessToken;

@end
