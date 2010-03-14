//
//  FJSKeyedViewControllerViewController.h
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
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
@property(nonatomic,readonly,retain)UIViewController *currentViewController;
@property(nonatomic,readonly,retain)NSString *currentViewControllerKey;

@property(nonatomic,readonly,retain)UIViewController *previousViewController;
@property(nonatomic,readonly,retain)NSString *previousViewControllerKey;

@property(nonatomic,readonly)NSArray *allKeys;

@property(nonatomic,assign)FJSAnimationType animationType;
@property(nonatomic,assign)FJSAnimationDirection animationDirection;
@property(nonatomic,assign)float animationDuration;


- (void)setController:(UIViewController*)controller forKey:(NSString*)key;
- (void)setControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key;
- (void)setControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key;

- (UIViewController*)viewControllerForKey:(NSString*)key;

- (void)loadControllerForKey:(NSString*)key;

- (NSString*)loadController:(UIViewController*)controller;

@end

