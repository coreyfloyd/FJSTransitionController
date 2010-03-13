//
//  FJSKeyedViewControllerAppDelegate.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import "FJSKeyedViewControllerAppDelegate.h"
#import "FJSKeyedViewController.h"
#import "DummyViewController.h"
#import "AnotherViewController.h"

@implementation FJSKeyedViewControllerAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	DummyViewController* vc = [[DummyViewController alloc] initWithNibName:@"DummyViewController" bundle:nil];
	
	//[self.viewController loadController:vc];
	
	[self.viewController setController:vc forKey:@"Dummy"];
	
	[self.viewController loadControllerForKey:@"Dummy"];
	
	
	AnotherViewController* a = [[AnotherViewController alloc] initWithNibName:@"AnotherViewController" bundle:nil];
	
	[self.viewController setController:a forKey:@"Another"];

	
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
