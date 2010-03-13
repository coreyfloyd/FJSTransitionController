//
//  UIViewController+FJSKeyedViewController.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "UIViewController+FJSKeyedViewController.h"
#import "FJSKeyedViewController.h"

@implementation UIViewController (FJSKeyedViewController)

static NSMutableDictionary* _controllers = nil;

- (void)setKeyedViewController:(FJSKeyedViewController*)keyedViewController{
	
	if(_controllers == nil)
		_controllers = [[NSMutableDictionary alloc] init];
	
	[_controllers setObject:keyedViewController forKey:[NSString stringWithFormat:@"%i", [self hash]]];
	
}

- (FJSKeyedViewController*)keyedViewController{
	
	return [_controllers objectForKey:[NSString stringWithFormat:@"%i", [self hash]]];
}

@end
