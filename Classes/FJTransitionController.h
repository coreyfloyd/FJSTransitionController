//
//  FJTransitionController.h
//  FJTransitionController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//
//
// This class allows you to load arbitrary view controllers and animate view transitions
// It currently supports 5 types of animations provided by the excellent FTUtils
//
// It is a full replacement for UINavigationController or UItabBarController
//
// It provides your VCs all proper viewDid/WillAppear and viewDid/WillDisapear messages
// WITH proper timing (Using bits and pieces of code from SDNextRUnloopProxy)
//
// It depends on another open source projects, FTUtils
// 
//


#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    FJPositionCenter = 0,
    FJPositionOffScreenTop,
    FJPositionOffScreenRight,
    FJPositionOffScreenBottom,
    FJPositionOffScreenLeft,
    FJPositionOffScreenTopLeft,
    FJPositionOffScreenTopRight,
    FJPositionOffScreenBottomLeft,
    FJPositionOffScreenBottomRight
} FJPosition;

//Use this method to easily set center points of views
void setViewControllerCenterPoint(FJPosition position, UIViewController* viewcontroller);


/****************************************************************************/

//This UIViewController category allows you to get a pointer to the TransitionController that a VC has been added to.

@class FJTransitionController;

@interface UIViewController (FJTransitionController)

@property(nonatomic, readonly) FJTransitionController* transitionController;

@end


/****************************************************************************/


@interface FJTransitionController : UIViewController {

    NSMutableDictionary* controllers;
	NSMutableDictionary* controllerData;
	    
    NSMutableArray* viewControllerKeyHistory;
	
	BOOL isTransitioning;

}

/****************************************************************************/
/* 
 
 Use these 3 methods to add view controllers to the Transition Controller
 
 Setting the VCs using Class/Nibs is better for memory as the View Controllers won't be instantiated until needed …AND they can be re-instantiated as well. Sweet!
 
 If You also need a navigation controller for drill down. Pass YES for useNavigationController for the VCs you wish to have "wrapped" in a navigation controller. The rest happens automagically.
 
*/

//This one allows you to add a VC by providing the class
//Passing nil key will blow up!!
- (void)setViewControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key withNavigationController:(BOOL)useNavigationController;

//This one is the same, but you ca point to a nib as well
- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)nibName bundle:(NSBundle*)bundle forKey:(NSString*)key withNavigationController:(BOOL)useNavigationController;

//This one allows you to add a fully instantiated VC
//Passing nil vc will blow up!!
//Be warned, VCs added this way will be deallocated after they are removed from the Screen, eventually. I haven't decided when.
- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key;



/****************************************************************************/

//This is how we display a VC's view
- (UIViewController*)loadViewControllerForKey:(NSString*)key;

//Now it gets fun. Specify animations for each view controller
//Note if you set useNavigationController to YES, the view controller returned will be the navigation controller
- (void)loadViewControllerForKey:(NSString*)key
              appearingViewOnTop:(BOOL)viewOnTop //some animations need the new view on top
                      setupBlock:(void (^)(UIViewController* appearingViewController))setupBlock //start hidden or offscreen?
     appearingViewAnimationBlock:(void (^)(UIViewController* appearingViewController))appearingViewAnimationBlock
  disappearingViewAnimationBlock:(void (^)(UIViewController* disappearingViewController))disappearingViewAnimationBlock; //set the properties you want to animate. You can also specify animation options in each animation block i.e. [UIView setAnimationDuration:1.5]


//OMG, I can get really fancy with my own animations!

/*
- (void)loadViewControllerForKey:(NSString*)key
              appearingViewOnTop:(BOOL)viewOnTop
                      setupBlock:(void (^)(UIViewController* appearingViewController))setupBlock 
     appearingViewAnimationBlock:(CAAnimation* (^)(UIViewController* appearingViewController))appearingViewAnimationBlock 
  disappearingViewAnimationBlock:(CAAnimation* (^)(UIViewController* disappearingViewController))disappearingViewAnimationBlock;
*/

/****************************************************************************/
/*
 Info
*/
@property (nonatomic,readonly)UIViewController *activeViewController;
@property (nonatomic,readonly)NSString *activeViewControllerKey;

@property (nonatomic,readonly)UIViewController *lastViewController;
@property (nonatomic,readonly)NSString *lastViewControllerKey;

//Get all keys for all VCs
@property(nonatomic,readonly)NSArray *allKeys;

//get the history of view controllers. First key is the most recently shown view controller key
@property (nonatomic,readonly,retain)NSArray *viewControllerKeyHistory;

/* 
 The following mehtod will return a VC ONLY if one of the follwing scenarios is true:
 1. You provided a fully instantiated VC using setController:forKey: OR loadController:
 2. You have displayed a VC that you defined as a Class/Nib and it hasn't yet been dealloced
 
 The basic premise is: if I don't have fully instantiated VC in memory, I am not going to create one now just for you to look at.
*/
- (UIViewController*)viewControllerForKey:(NSString*)key;


/* 
 Do you want to know if a transition is happening right now?
 Note, the transition controller will not alow you to load a VC while a transition is in progress! 
 */

@property(nonatomic,assign, readonly)BOOL isTransitioning;


/****************************************************************************/

/*
 Release view controller. Cleans up memory if you do not need the VC ro be active
*/
- (void)releaseViewControllerForKey:(NSString*)key;

/* 
 Lets get rid of a VC
 Note: Removing the current view controller will not remove if from screen
 */
- (void)removeViewControllerForKey:(NSString*)key;

/*
 lets get rid of all thoe nast VCs taking up space
 Note: this is called automatically upon receiving memory warnings
*/
- (void)deallocateAllInactiveViewControllers;




@end



