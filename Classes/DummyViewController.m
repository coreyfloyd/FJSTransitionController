//
//  DummyViewController.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/13/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "DummyViewController.h"
#import "FJTransitionController.h"

@implementation DummyViewController


- (IBAction)newxtVC{

	//[self.transitionController loadViewControllerForKey:@"Another"]; 
	
    [self.transitionController loadViewControllerForKey:@"Another" 
                                     appearingViewOnTop:YES 
                                             setupBlock:^(UIViewController *appearingViewController) {
                                         
                                                 appearingViewController.view.alpha = 0;
                                                 setViewControllerCenterPoint(FJPositionOffScreenBottom, appearingViewController);
                                         
                                     } appearingViewAnimationBlock:^(UIViewController *appearingViewController) {
                                         
                                         appearingViewController.view.alpha = 1.0;
                                         setViewControllerCenterPoint(FJPositionCenter, appearingViewController);

                                    } disappearingViewAnimationBlock:^(UIViewController *disappearingViewController) {
                                    
                                        setViewControllerCenterPoint(FJPositionOffScreenTop, disappearingViewController);

                                        
                                     }];
}

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
