//
//  NMImageCache.m
//  NoMo
//
//  Created by Costas Harizakis on 07/12/2016.
//  Copyright © 2016 MiiCard. All rights reserved.
//

#import "NMImageCache.h"


@implementation NMImageCache

- (UIImage *)imageforRequest:(NSURLRequest *)request withAdditionalIdentifier:(NSString *)identifier
{
	NSURLComponents *imageURL = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
	
	if ([imageURL.scheme isEqualToString:@"assets"]) {
		NSString *imageName = imageURL.path;
		UIImage *image = [UIImage imageNamed:imageName];
		
		return image;
	}
	
	return [super imageforRequest:request withAdditionalIdentifier:identifier];
}

@end
