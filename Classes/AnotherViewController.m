//
//  AnotherViewController.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/13/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "AnotherViewController.h"
#import "FJTransitionController.h"


@implementation AnotherViewController


- (IBAction)pop{
    
	//[[self transitionController] loadViewControllerForKey:[self.transitionController lastViewControllerKey]];
	//[self.transitionController loadViewControllerForKey:@"Dummy"];
    
    [self.transitionController loadViewControllerForKey:[self.transitionController lastViewControllerKey] 
                                     appearingViewOnTop:NO
                                             setupBlock:^(UIViewController *appearingViewController) {
                                                 
                                                 //appearingViewController.view.alpha = 0;
                                                 //setViewControllerCenterPoint(FJPositionOffScreenTopLeft, appearingViewController);
                                                 
                                             } appearingViewAnimationBlock:^(UIViewController *appearingViewController) {
                                                 
                                                 //appearingViewController.view.alpha = 1.0;
                                                 //setViewControllerCenterPoint(FJPositionCenter, appearingViewController);
                                                 
                                             } disappearingViewAnimationBlock:^(UIViewController *disappearingViewController) {
                                                 
                                                 setViewControllerCenterPoint(FJPositionOffScreenBottomRight, disappearingViewController);
                                                 
                                                 
                                             }];

	
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"Hello");
}



@end
