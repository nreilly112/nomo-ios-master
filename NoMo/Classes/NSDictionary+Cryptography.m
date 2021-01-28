//
//  NSDictionary+Cryptography.m
//  NoMo
//
//  Created by Costas Harizakis on 09/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NSDictionary+Cryptography.h"


@implementation NSDictionary (Cryptography)

- (instancetype)initWithContentsOfEncryptedFile:(NSString *)path password:(NSString *)password
{
	__autoreleasing NSError *error;
	
	NSData *encryptedData = [NSData dataWithContentsOfFile:path options:0 error:&error];
	
	if (error) {
		NSLog(@"[NSDictionary::initWithContentsOfEncryptedFile] [%@]", error.description);
		return nil;
	}
	
	NSData *data = [RNDecryptor decryptData:encryptedData withPassword:password error:&error];
	
	if (error) {
		NSLog(@"[NSDictionary::initWithContentsOfEncryptedFile] [%@]", error.description);
		return nil;
	}
	
	id dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	return [self initWithDictionary:dictionary];
}

+ (instancetype)dictionaryWithContentsOfEncryptedFile:(NSString *)path password:(NSString *)password
{
	return [[NSDictionary alloc] initWithContentsOfEncryptedFile:path password:password];
}

- (BOOL)writeToEncryptedFile:(NSString *)path password:(NSString *)password atomically:(BOOL)useAuxiliaryFile
{
	return [self writeToEncryptedFile:path password:password atomically:useAuxiliaryFile error:nil];
}

- (BOOL)writeToEncryptedFile:(NSString *)path password:(NSString *)password atomically:(BOOL)useAuxiliaryFile error:(NSError * __autoreleasing *)error
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	NSData *encryptedData = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:error];
	NSDataWritingOptions options = 0;
	
	if (useAuxiliaryFile) {
		options = NSDataWritingAtomic;
	}
	
	return [encryptedData writeToFile:path options:options error:error];
}

@end
