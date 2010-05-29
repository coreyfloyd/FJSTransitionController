//
//  FJSTransitionController.h
//  FJSTransitionController
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
#import "FTAnimation.h"

//Types that are used to set the transition animation

typedef enum {
	FJSAnimationDirectionTop = 0,
	FJSAnimationDirectionRight = 1,
	FJSAnimationDirectionBottom = 2,
	FJSAnimationDirectionLeft = 3
}FJSAnimationDirection;

typedef enum {
	FJSAnimationTypeNone = 0,
	FJSAnimationTypeSlide,
	FJSAnimationTypeFade,
	FJSAnimationTypeFall,
	FJSAnimationTypePop,
	FJSAnimationTypeSlideWithBounce,
	FJSAnimationTypePush,
	FJSAnimationTypePushWithBounce,
	FJSAnimationTypeReveal
}FJSAnimationType;



/****************************************************************************/

//This UIViewController category allows you to get a pointer to the TransitionController that a VC has been added to.

@class FJSTransitionController;

@protocol FJSTransitionControllerDelegate;

@interface UIViewController (FJSTransitionController)

@property(nonatomic, readonly) FJSTransitionController* transitionController;

@end


/****************************************************************************/


@interface FJSTransitionController : UIViewController {

	NSMutableDictionary* controllers;
	NSMutableDictionary* controllerMetaData;
	
	UIViewController* currentViewController;
	NSString* currentViewControllerKey;
	
	UIViewController* previousViewController;
	NSString* previousViewControllerKey;
	
	FJSAnimationType animationType;
	FJSAnimationDirection animationDirection;
	float animationDuration;
	
	int animationCounter;

	BOOL isTransitioning;
	BOOL isAnimating;
    
    id<FJSTransitionControllerDelegate> delegate;

}

/****************************************************************************/
/* 
 Use these 2 methods to add view controllers to the Keyed VC
 Setting the VCs using Class/Nibs is better for memory as the View Controllers won't be instantiated until needed
 …AND they can be re-instantiated as well. Sweet!
 */

//This one allows you to add a VC by providing the class
- (void)setViewControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key;

//This one is the same, but you ca point to a nib as well
- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key;


//This one allows you to add a fully instantiated VC to the KVC
//Be warned, VCs added this way will be deallocated after they are removed from the Screen, eventually. I haven't decided when.
- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key;


/****************************************************************************/

//This is how we display a VC's view, if you specified a transition animation it happens automatically.
- (UIViewController*)loadViewControllerForKey:(NSString*)key;


//Convienence, like a pop you don't have to know what came before you.
- (void)loadPreviousViewController;

/****************************************************************************/
/* 
 Ok, so you want to provide a fully instantiated VC. Well, your choice. Keep a few things in mind though:

 1. You don't get memory saving benifits, your VC will sit in memory just taking up space.
 2. If we get a memory waning, and the VC's view isn't on screen, BUH-BY!
 
*/


//Lets provide a VC and display its view in one step
- (BOOL)loadViewController:(UIViewController*)controller forKey:(NSString *)key;

//now we will automatically generate a key for you, lazy.
- (NSString*)loadViewController:(UIViewController*)controller;



//Get all keys for all VCs
@property(nonatomic,readonly)NSArray *allKeys;

//Get the current VC
@property(nonatomic,readonly,retain)UIViewController *currentViewController;
@property(nonatomic,readonly,retain)NSString *currentViewControllerKey;

//Get the previous VC
@property(nonatomic,readonly,retain)UIViewController *previousViewController;
@property(nonatomic,readonly,retain)NSString *previousViewControllerKey;


/****************************************************************************/
/* 
 Lets get rid of a VC
 Technically, using the setController:forKey: method with nil can work as well
 Note: Removing the current view controller will not remove if from screen
*/
- (void)removeViewControllerForKey:(NSString*)key;

/****************************************************************************/

//You can get some info back
- (Class)viewControllerClassForKey:(NSString*)key;

/* 
 The following mehtod will return a VC ONLY if one of the follwing scenarios is true:
 1. You provided a fully instantiated VC using setController:forKey: OR loadController:
 2. You have displayed a VC that you defined as a Class/Nib and it hasn't yet been dealloced
 
 The basic premise is: if I don't have fully instantiated VC in memory, I am not going to create one now just for you to look at.
*/
- (UIViewController*)viewControllerForKey:(NSString*)key;


/****************************************************************************/
/* 
 So you want to animate the transition, well provide some info, fool!
 Animation settings always apply to the next view controller you load. You cannot associate animations with specific view controllers. 
 Meaning: Don't assume the anaimation settins are correct, always reset them before attempting a transition.
*/
@property(nonatomic,assign)FJSAnimationType animationType; //Default is FJSAnimationTypeNone
@property(nonatomic,assign)FJSAnimationDirection animationDirection; //Default is FJSAnimationDirectionTop
@property(nonatomic,assign)float animationDuration; //Default is 0.0, that's fast!

/* 
 Do you want to know if a transition is happening right now?
 Note, the transition controller will not alow you to load a VC while a transition is in progress! 
*/
@property(nonatomic,assign)BOOL isTransitioning;

//Do you ant to know if an animation is going on?
@property(nonatomic,assign)BOOL isAnimating;

/* 
 Retrieve the TtansitionController a VC is associated with
 this works the same as the transitionController property in the UIViewController category
 It is mostly here for convienience
*/
+ (FJSTransitionController*)transitionControllerForViewController:(UIViewController*)controller;


/* 
 Specify the delegate.
 But why?
 
 */

@property(nonatomic,assign)id<FJSTransitionControllerDelegate> delegate;

@end

/* 
 I'll tell you why.
 Because you want to do 2 things:
 1. You want to reap the memory saving benifits of the FJSTransitionController, but
 2. You also need a navigation controller for drill down.
 
 Well we have the delegate method for you:
 
 Simply return YES for keys whose VCs you wish to have "wrapped" in a navigation controller.
 The rest happens autmagically.
 
 (I know it is a long convaluted method name)
 
 */


@protocol FJSTransitionControllerDelegate <NSObject>

@optional
- (BOOL)shouldWrapNavigationControllerAroundViewControllerForKey:(NSString*)key;

@end


