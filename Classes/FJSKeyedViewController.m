//
//  FJSKeyedViewControllerViewController.m
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import "FJSKeyedViewController.h"
#import "UIViewController+FJSKeyedViewController.h"
#import "FTAnimation.h"
#import "SDNextRunloopProxy.h"
#import <objc/runtime.h>

static NSString* kClassNameKey = @"kClassNameKey";
static NSString* kNibNameKey = @"kNibNameKey";
static NSString* kBundleNameKey = @"kNibNameKey";



@interface FJSKeyedViewController ()

@property(nonatomic,retain)NSMutableDictionary *controllers;
@property(nonatomic,retain)NSMutableDictionary *controllerMetaData;

@property(nonatomic,readwrite,retain)UIViewController *currentViewController;
@property(nonatomic,readwrite,retain)NSString *currentViewControllerKey;

@property(nonatomic,readwrite,retain)UIViewController *previousViewController;
@property(nonatomic,readwrite,retain)NSString *previousViewControllerKey;


- (void)showViewController:(UIViewController*)viewController;
- (UIViewController*)controllerWithMetaData:(NSDictionary*)metaData;
- (NSDictionary*)metaDataForClass:(Class)class nib:(NSString*)aNibName bundle:(NSString*)bundle;


- (void)prepareViewController:(UIViewController*)viewController;
- (void)showViewController:(UIViewController*)viewController;


- (void)prepareViewControllerForRemoval:(UIViewController*)viewController;
- (void)removeViewForViewController:(UIViewController*)viewController;
	
- (void)unloadViewController:(UIViewController*)viewController;
- (void)unloadViewControllerForKey:(NSString*)key;


@end

@implementation FJSKeyedViewController

@synthesize controllers;
@synthesize controllerMetaData;
@synthesize animationType;
@synthesize animationDirection;

@synthesize currentViewController;
@synthesize currentViewControllerKey;
@synthesize previousViewController;
@synthesize previousViewControllerKey;



- (void)dealloc {
	[previousViewController release], previousViewController = nil;
	[previousViewControllerKey release], previousViewControllerKey = nil;	
	[currentViewControllerKey release], currentViewControllerKey = nil;
	[currentViewController release], currentViewController = nil;
	[controllers release], controllers = nil;
	[controllerMetaData release], controllerMetaData = nil;
    [super dealloc];
}

#pragma -
#pragma mark UIViewController

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	
	for(UIViewController *eachVC in self.controllers){
		
		[eachVC didReceiveMemoryWarning];		
		
		if([eachVC.view superview] == nil){
			
			//TODO: can i nil these out? dont think so, wait i can nil out anything i have metadata for. hmm…
		}
	}

	//TODO: any other cleanup?
	
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload{
	
	[self.currentViewController viewDidUnload]; 
	//TODO: do I need to send this to all VCs?
}

- (void)viewDidLoad{
	
	[super viewDidLoad];
	
}




#pragma mark -
#pragma mark Accessors

- (NSMutableDictionary *)controllers
{
	if(controllers == nil)
		self.controllers = [NSMutableDictionary dictionary];
	
    return [[controllers retain] autorelease]; 
}


- (NSMutableDictionary *)controllerMetaData
{
	if(controllerMetaData == nil)
		self.controllerMetaData = [NSMutableDictionary dictionary];

    return [[controllerMetaData retain] autorelease]; 
}


- (NSArray*)allKeys{
	
	return [self.controllers allKeys];
	
}

- (UIViewController*)viewControllerForKey:(NSString*)key{
	
	return [self.controllers objectForKey:key];
}

#pragma mark -
#pragma mark Add VC

- (void)setController:(UIViewController*)controller forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];
	
	[self.controllers setObject:controller forKey:key];
	
	[controller setKeyedViewController:self];
	
}
- (void)setControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key{

	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];

	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:nil bundle:nil] forKey:key];
	
}
- (void)setControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];

	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:aNibName bundle:bundle] forKey:key];

}	

#pragma mark -
#pragma mark Load VC

- (NSString*)loadController:(UIViewController*)controller{
	
	NSString* key = [NSString stringWithFormat:@"%i", [controller hash]];
	
	[self setController:controller forKey:key];
	[self loadControllerForKey:key];
	
	return key;
}


- (void)loadControllerForKey:(NSString*)key{
	
	UIViewController* vc = [self.controllers objectForKey:key];
	
	if(vc==nil){
		
		vc = [self controllerWithMetaData:[self.controllerMetaData objectForKey:key]];

	}
	
	if(vc==nil)
		return;

	self.previousViewController = self.currentViewController;
	self.previousViewControllerKey = self.currentViewControllerKey;
	
	self.currentViewController = vc;
	self.currentViewControllerKey = key;
	
	//TODO: remove or move this
	[vc.view setFrame:self.view.bounds];

	[[self nextRunloopProxy] prepareViewController:vc];
}

- (void)prepareViewController:(UIViewController*)viewController{

	[viewController viewWillAppear:YES];
	
	[[self nextRunloopProxy] showViewController:viewController];
}

- (void)showViewController:(UIViewController*)viewController{
	
	[self.view addSubview:viewController.view];

	[[viewController nextRunloopProxy] viewDidAppear:YES];
	
}


#pragma mark -
#pragma mark Unload VC


- (void)prepareViewControllerForRemoval:(UIViewController*)viewController{
	
	[viewController viewWillDisappear:YES];
	
	[[self nextRunloopProxy] removeViewForViewController:viewController];
	
}

- (void)removeViewForViewController:(UIViewController*)viewController{
	
	[viewController.view removeFromSuperview];
	
	[[viewController nextRunloopProxy] viewDidDisappear:YES];
	
}


- (void)unloadViewController:(UIViewController*)viewController{
	
	[viewController viewDidUnload];
	
	//TODO: i don't know? is this it, should I dealloc?
	
	
}


- (void)unloadViewControllerForKey:(NSString*)key{
	
	[self unloadViewController:[self viewControllerForKey:key]];
	
	
}

#pragma mark -
#pragma mark metaData

- (UIViewController*)controllerWithMetaData:(NSDictionary*)metaData{
	
	UIViewController* controller = nil;
	
	NSString* className = [metaData objectForKey:kClassNameKey];
	
	if(className == nil)
		return nil;
	
	Class vcClass = NSClassFromString(className);
	
	
	NSString* nib = [metaData objectForKey:kNibNameKey];
	
	if(nib==nil){
		
		controller = [[vcClass alloc] init];
		
	}else{
		
		NSBundle* bundle = [metaData objectForKey:kBundleNameKey];
		
		controller = [[vcClass alloc] initWithNibName:nib bundle:bundle];
		
	}
	
	[controller setKeyedViewController:self];

	return controller;
}


- (NSDictionary*)metaDataForClass:(Class)class nib:(NSString*)aNibName bundle:(NSString*)bundle{
	
	NSMutableDictionary* metaData = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSString *className = NSStringFromClass(class);	
	
	if(className == nil)
		return nil;
	
	[metaData setObject:(NSString*)className forKey:kClassNameKey];
	
	if(aNibName != nil)
		[metaData setObject:aNibName forKey:kNibNameKey];
	
	if(bundle != nil)
		[metaData setObject:bundle forKey:kBundleNameKey];
	
	return metaData;
	
} 



@end
