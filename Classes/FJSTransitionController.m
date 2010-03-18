//
#import "FJSTransitionController.h"
#import "FTAnimation.h"
#import "SDNextRunloopProxy.h"
#import <objc/runtime.h>

static NSString* kClassNameKey = @"kClassNameKey";
static NSString* kNibNameKey = @"kNibNameKey";
static NSString* kBundleNameKey = @"kBundleNameKey";




@interface UIViewController (SetFJSTransitionController)

- (void)setTransitionController:(FJSTransitionController*)transitionController;

@end



@implementation UIViewController (SetFJSTransitionController)

static NSMutableDictionary* _controllers = nil;

- (void)setTransitionController:(FJSTransitionController*)transitionController{
	
	if(_controllers == nil)
		_controllers = [[NSMutableDictionary alloc] init];
	
	[_controllers setObject:transitionController forKey:[NSString stringWithFormat:@"%i", [self hash]]];
	
}

@end



@implementation UIViewController (FJSTransitionController)

- (FJSTransitionController*)transitionController{
	
	return [FJSTransitionController transitionControllerForViewController:self];
}

@end



@interface FJSTransitionController ()

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
- (void)finalizeViewController:(UIViewController*)viewController;


- (void)prepareViewControllerForRemoval:(UIViewController*)viewController;
- (void)removeViewForViewController:(UIViewController*)viewController;
	
- (void)unloadViewController:(UIViewController*)viewController;
- (void)unloadViewControllerForKey:(NSString*)key;

- (void)prepareAnimationForViewController:(UIViewController*)viewController;

@end

@implementation FJSTransitionController

@synthesize controllers;
@synthesize controllerMetaData;
@synthesize animationType;
@synthesize animationDirection;
@synthesize animationDuration;

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
	
	for(NSString* eachKey in self.controllers){
		
		UIViewController *eachVC = [self.controllers objectForKey:eachKey];
		
		//send a memory warning
		[eachVC didReceiveMemoryWarning];		
		
		//if a vc is offscreen, kill it. I am ruthless
		if([eachVC.view superview] == nil){
			
			[eachVC viewDidUnload];
			[self.controllers setObject:nil forKey:eachKey];
			
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

- (Class)viewControllerClassForKey:(NSString*)key{
	
	return NSClassFromString([[self.controllerMetaData objectForKey:key] objectForKey:kClassNameKey]);
	
}

#pragma mark -
#pragma mark Add VC

- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];
	
	[self.controllers setObject:controller forKey:key];
	[self.controllerMetaData removeObjectForKey:key];
	
	[controller setTransitionController:self];
	
}
- (void)setViewControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key{

	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];

	[self.controllers removeObjectForKey:key];
	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:nil bundle:nil] forKey:key];

	
}
- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self unloadViewControllerForKey:key];

	[self.controllers removeObjectForKey:key];
	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:aNibName bundle:bundle] forKey:key];

}	

- (void)removeViewControllerForKey:(NSString*)key{
	
	[self.controllers removeObjectForKey:key];
	[self.controllerMetaData removeObjectForKey:key];
	
}

#pragma mark -
#pragma mark Load VC

- (NSString*)loadViewController:(UIViewController*)controller{
	
	NSString* key = [NSString stringWithFormat:@"%i", [controller hash]];
	
	[self setViewController:controller forKey:key];
	[self loadViewControllerForKey:key];
	
	return key;
}

- (void)loadViewController:(UIViewController*)controller forKey:(NSString *)key{
	
	[self setViewController:controller forKey:key];
	[self loadViewControllerForKey:key];
	
}

- (void)loadViewControllerForKey:(NSString*)key{
	
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
	
	[self.previousViewController viewWillDisappear:YES];
	self.previousViewController.view.userInteractionEnabled = NO;
	
	[self.view addSubview:viewController.view];

	
	[self prepareAnimationForViewController:viewController];

	[[self nextRunloopProxy] finalizeViewController:viewController];
	
}

- (void)finalizeViewController:(UIViewController*)viewController{
	
	[self.previousViewController viewDidDisappear:YES];
	viewController.view.userInteractionEnabled = YES;

	[viewController viewDidAppear:YES];
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
	
	[controller setTransitionController:self];

	return [controller autorelease];
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

#pragma mark -
#pragma mark Amimation

- (void)prepareAnimationForViewController:(UIViewController*)viewController{
	
	if(self.animationType == FJSAnimationTypeNone)
		return;
	
	viewController.view.hidden = YES;
	
	if(self.animationType == FJSAnimationTypeSlide){
		
		[viewController.view slideInFrom:self.animationDirection duration:self.animationDuration delegate:self];
		
	}else if(self.animationType == FJSAnimationTypeFade){
		
		[viewController.view fadeIn:self.animationDuration delegate:self];
		
	}else if(self.animationType == FJSAnimationTypeFall){
		
		[viewController.view fallIn:self.animationDuration delegate:self];
		
	}else if(self.animationType == FJSAnimationTypePop){
		
		[viewController.view popIn:self.animationDuration delegate:self];
		
	}else if(self.animationType == FJSAnimationTypeSlideWithBounce){
		
		[viewController.view backInFrom:self.animationDirection withFade:NO duration:self.animationDuration delegate:self];
		
	}else if(self.animationType == FJSAnimationTypePush){
		
		int direction = self.animationDirection;
		
		direction += 2;
		
		direction = direction % 4;
		
		
		[self.previousViewController.view slideOutTo:direction duration:self.animationDuration delegate:nil];
		[viewController.view slideInFrom:self.animationDirection duration:self.animationDuration delegate:self];

	}else if(self.animationType == FJSAnimationTypePushWithBounce){
		
		int direction = self.animationDirection;
		
		direction += 2;
		
		direction = direction % 4;
		
		[self.previousViewController.view slideOutTo:direction duration:(self.animationDuration*.7) delegate:nil];
		[viewController.view backInFrom:self.animationDirection withFade:NO duration:self.animationDuration delegate:self];

		
	}

}




+ (FJSTransitionController*)transitionControllerForViewController:(UIViewController*)controller{
	
	return [_controllers objectForKey:[NSString stringWithFormat:@"%i", [controller hash]]];

	
}




@end
