//
//  FJSKeyedViewControllerViewController.h
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//
//
// This class allows you to load arbitrary view controllers and animate view transitions
// It currently supports 5 types of animations provided by the excellent FTUtils
//
// It is a full replacement for UINavigationController and UItabBarController
//
// It provides your VCs all proper viewDid/WillAppear and viewDid/WillDisapear messages
// WITH proper timing
//
// It depends on 2 other open source projects: FTUtils, and SDNextRunLoopProxy
//


#import <UIKit/UIKit.h>
#import "FTAnimation.h"

typedef enum {
	FJSAnimationDirectionTop = 0,
	FJSAnimationDirectionRight,
	FJSAnimationDirectionBottom,
	FJSAnimationDirectionLeft
}FJSAnimationDirection;

typedef enum {
	FJSAnimationTypeNone = 0,
	FJSAnimationTypeSlide,
	FJSAnimationTypeFade,
	FJSAnimationTypeFall,
	FJSAnimationTypePop,
	FJSAnimationTypeBack,
}FJSAnimationType;


@interface FJSKeyedViewController : UIViewController {

	NSMutableDictionary* controllers;
	NSMutableDictionary* controllerMetaData;
	
	UIViewController* currentViewController;
	NSString* currentViewControllerKey;
	
	UIViewController* previousViewController;
	NSString* previousViewControllerKey;
	
	FJSAnimationType animationType;
	FJSAnimationDirection animationDirection;
	float animationDuration;
}

//----------------------------------------------------------------------

//Use these 2 methods to add view controllers to the Keyed VC
//Setting the VCs using Class/Nibs is better for memory as the View Controllers won't be instantiated until needed
// …AND they can be re-instantiated as well. Sweet!

//This one allows you to add a VC by providing the class
- (void)setControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key;

//This one is the same, but you ca point to a nib as well
- (void)setControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key;


//This one allows you to add a fully instantiated VC to the KVC
//Be warned, VCs added this way will be deallocated after they are removed from the Screen, eventually. I haven't decided when.
- (void)setController:(UIViewController*)controller forKey:(NSString*)key;


//----------------------------------------------------------------------

//This is how we get a VC on screen
- (void)loadControllerForKey:(NSString*)key;

//Lets provide a VC and get it on screen in one step
- (NSString*)loadController:(UIViewController*)controller;

//Get all keys for all VCs
@property(nonatomic,readonly)NSArray *allKeys;

//Get the current VC
@property(nonatomic,readonly,retain)UIViewController *currentViewController;
@property(nonatomic,readonly,retain)NSString *currentViewControllerKey;

//Get the previous VC
@property(nonatomic,readonly,retain)UIViewController *previousViewController;
@property(nonatomic,readonly,retain)NSString *previousViewControllerKey;


//----------------------------------------------------------------------

//Lets get rid of a VC
//Technically, using the setController:forKey: method with nil can work as well
//But removing the visable view controller will not kill it, it will remain in memory until replaced
- (void)removeControllerForKey:(NSString*)key;

//----------------------------------------------------------------------

//You can get some info back
- (Class)viewControllerClassForKey:(NSString*)key;

//The following mehtod will return a VC ONLY if one of the follwing scenarios is true:
//1. You provided a fully instantiated VC using setController:forKey: OR loadController:
//2. You have displayed a VC that you defined as a Class/Nib and it hasn't yet been dealloced

//The basic premise is, if you didn't give me a fully instantiated VC, I am not going to create one now just for you to look at.
- (UIViewController*)viewControllerForKey:(NSString*)key;


//----------------------------------------------------------------------

//So you want to animate the transition, well provide some info, fool!
//Animation settings apply to the next view controller you load. You cannot associate animations with specific view controllers.

@property(nonatomic,assign)FJSAnimationType animationType; //Default is FJSAnimationTypeNone
@property(nonatomic,assign)FJSAnimationDirection animationDirection; //Default is FJSAnimationDirectionTop
@property(nonatomic,assign)float animationDuration; //Default is 0.0, that is fast!





@end

