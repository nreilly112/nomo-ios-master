//
//  NSDictionary+Cryptography.h
//  NoMo
//
//  Created by Costas Harizakis on 09/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//


@interface NSDictionary (Cryptography)

- (instancetype)initWithContentsOfEncryptedFile:(NSString *)path password:(NSString *)password;
+ (instancetype)dictionaryWithContentsOfEncryptedFile:(NSString *)path password:(NSString *)password;

- (BOOL)writeToEncryptedFile:(NSString *)path password:(NSString *)password atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToEncryptedFile:(NSString *)path password:(NSString *)password atomically:(BOOL)useAuxiliaryFile error:(NSError * __autoreleasing *)error;

@end
