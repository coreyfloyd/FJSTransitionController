//
//  FJSKeyedViewControllerAppDelegate.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import "FJSKeyedViewControllerAppDelegate.h"
#import "FJSTransitionController.h"
#import "DummyViewController.h"
#import "AnotherViewController.h"

@implementation FJSKeyedViewControllerAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[self.viewController setViewControllerWithClass:[DummyViewController class] nib:@"DummyViewController" bundle:nil forKey:@"Dummy"];
		
	[self.viewController loadViewControllerForKey:@"Dummy"];
	
	
	AnotherViewController* a = [[AnotherViewController alloc] initWithNibName:@"AnotherViewController" bundle:nil];
	
	[self.viewController setViewController:a forKey:@"Another"];

	
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
