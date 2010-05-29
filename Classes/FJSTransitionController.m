//
#import "FJSTransitionController.h"
#import "FTAnimation.h"
#import "NSObject+Proxy.h"
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

@property(nonatomic,assign)int animationCounter;


- (UIViewController*)controllerWithMetaData:(NSDictionary*)metaData;
- (NSDictionary*)metaDataForClass:(Class)class nib:(NSString*)aNibName bundle:(NSString*)bundle;

- (void)prepareViewController;
- (void)willShowViewController;
- (void)showViewController;
- (void)didShowViewController;

- (void)prepareAnimationForViewController;

@end

@implementation FJSTransitionController

@synthesize controllers;
@synthesize controllerMetaData;
@synthesize animationType;
@synthesize animationDirection;
@synthesize animationDuration;
@synthesize isAnimating;
@synthesize animationCounter;

@synthesize isTransitioning;

@synthesize currentViewController;
@synthesize currentViewControllerKey;
@synthesize previousViewController;
@synthesize previousViewControllerKey;
@synthesize delegate;







- (void)dealloc {
    delegate = nil;
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

	NSArray *keys = [self.controllers allKeys];
	for(NSString* eachKey in keys){
		
		UIViewController *eachVC = [self.controllers objectForKey:eachKey];
		
		//send a memory warning
		[eachVC didReceiveMemoryWarning];		
		
		//if a vc is offscreen, kill it. I am ruthless
		if([eachVC.view superview] == nil){
			
			[eachVC viewDidUnload];
			[self.controllers removeObjectForKey:eachKey]; //poof!
			
		}
	}

	//TODO: any other cleanup?
	
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload{
	
    NSArray *keys = [self.controllers allKeys];

	for(NSString* eachKey in keys){
        
		UIViewController *eachVC = [self.controllers objectForKey:eachKey];
        
        [eachVC viewDidUnload];
        
    }
}

- (void)viewDidLoad{
	
	[super viewDidLoad];
	//TODO: do I really need this?
    [self.currentViewController viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.currentViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self.currentViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.currentViewController viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self.currentViewController viewDidDisappear:animated];
    
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
	
    UIViewController* vc = [self.controllers objectForKey:key];
    
    if([vc isKindOfClass:[UINavigationController class]]){
        
        vc = [[(UINavigationController*)vc viewControllers] objectAtIndex:0]; 
        
    }
    
	return vc;
}

- (Class)viewControllerClassForKey:(NSString*)key{
	
	return NSClassFromString([[self.controllerMetaData objectForKey:key] objectForKey:kClassNameKey]);
	
}

#pragma mark -
#pragma mark Add VC

- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	    
    [controller setTransitionController:self];
    
    if([delegate respondsToSelector:@selector(shouldWrapNavigationControllerAroundViewControllerForKey:)] &&
       [delegate shouldWrapNavigationControllerAroundViewControllerForKey:key]){
        
        UINavigationController* nav = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];    
        controller = nav;
    }
    
	
	[self.controllers setObject:controller forKey:key];
	[self.controllerMetaData removeObjectForKey:key];
	
	
}
- (void)setViewControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key{

	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
	[self.controllers removeObjectForKey:key];
	[self.controllerMetaData setObject:[self metaDataForClass:viewControllerClass nib:nil bundle:nil] forKey:key];

	
}
- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)aNibName bundle:(NSString*)bundle forKey:(NSString*)key{
	
	if([self.currentViewControllerKey isEqualToString:key])
		return;
	
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
	
	if(isTransitioning)
		return nil;
	
	NSString* key = [NSString stringWithFormat:@"%i", [controller hash]];
	
	[self setViewController:controller forKey:key];
	[controller setTransitionController:self];
	if([self loadViewControllerForKey:key] == nil)
		return NO;
	
	return key;
}

- (BOOL)loadViewController:(UIViewController*)controller forKey:(NSString *)key{

	if(isTransitioning)
		return NO;
	
	[self setViewController:controller forKey:key];
	[controller setTransitionController:self];
	if([self loadViewControllerForKey:key] == nil)
		return NO;
	
	return YES;
	
}

- (UIViewController*)loadViewControllerForKey:(NSString*)key{
	
		if(isTransitioning)
			return nil;
		
		if([key isEqualToString:self.currentViewControllerKey]){
			UIViewController* vc = self.currentViewController;
			if([vc isKindOfClass:[UINavigationController class]])
				vc = [[(UINavigationController*)vc viewControllers] objectAtIndex:0];
			
			return vc;
		}
		
		UIViewController* vc = [self.controllers objectForKey:key];
		
		if(vc==nil){
			
			vc = [self controllerWithMetaData:[self.controllerMetaData objectForKey:key]];
			
			if(vc!=nil)
				[self.controllers setObject:vc forKey:key];
		}
		
		if(vc==nil)
			return nil;
		
	@synchronized(self){

		//Just in case the previous VC is the next (and not recoverable with metadata), we woould like to prevent deallocation
		[[self.previousViewController retain] autorelease];
		[[self.previousViewControllerKey retain] autorelease];
		
		self.previousViewController = self.currentViewController;
		self.previousViewControllerKey = self.currentViewControllerKey;
		
		self.currentViewController = vc;
		self.currentViewControllerKey = key;
		
		//Lock Transition Controller
		self.isTransitioning = YES;
		
		[[self nextRunloopProxy] prepareViewController];
		
	}
    
    if([vc isKindOfClass:[UINavigationController class]])
        vc = [[(UINavigationController*)vc viewControllers] objectAtIndex:0];
    
	return vc;

}

- (void)loadPreviousViewController{
	
	[self loadViewControllerForKey:self.previousViewControllerKey];
	
}

#pragma mark -
#pragma mark display sequence

- (UINavigationController*)wrapViewController:(UIViewController*)controller forKey:(NSString*)key{
 
	if([controller isKindOfClass:[UINavigationController class]]){
		return (UINavigationController*)controller;
	}
	
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
	[self.controllers setObject:nav forKey:key];
    
    return [nav autorelease];
}




- (void)prepareViewController{
    
    if([delegate respondsToSelector:@selector(shouldWrapNavigationControllerAroundViewControllerForKey:)] &&
       [delegate shouldWrapNavigationControllerAroundViewControllerForKey:self.currentViewControllerKey]){
                 
        self.currentViewController = [self wrapViewController:self.currentViewController 
                                                       forKey:self.currentViewControllerKey];
    
    }
        	
	[[self nextRunloopProxy] willShowViewController];
}

- (void)willShowViewController{

	[currentViewController.view setFrame:self.view.bounds];
	
	[currentViewController viewWillAppear:YES];
	
	[[self nextRunloopProxy] showViewController];
}



- (void)showViewController{
	
	[self.previousViewController viewWillDisappear:YES];
    
    [self.view addSubview:currentViewController.view];

	[self prepareAnimationForViewController];

    //If we aren't animating, then lets complete the proper calls
    //If we are animating, we defer to the animation Delegate method to fire the last bit of cleanup logic
    if(!self.isAnimating)
        [[self nextRunloopProxy] didShowViewController];
	
}

- (void)didShowViewController{
	
	[self.previousViewController viewDidDisappear:YES];

	[currentViewController viewDidAppear:YES];
    
	//Unlock Transition Controller
	
	if(!self.isAnimating)
		self.isTransitioning = NO;
	
	currentViewController.view.userInteractionEnabled = YES;
    
    [self.previousViewController.view removeFromSuperview];
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

- (void)prepareAnimationForViewController{
	
	if(self.animationType == FJSAnimationTypeNone)
		return;
	
	//Double checking, is we are going to start another animation, we don't want to be in the middle of one.
	if(self.isAnimating == YES)
		return;
	
	self.animationCounter = 0;
	self.isAnimating = YES;
	
	currentViewController.view.hidden = YES;
	
	if(self.animationType == FJSAnimationTypeSlide){
		
		[currentViewController.view slideInFrom:self.animationDirection inView:self.view duration:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypeFade){
		
		[currentViewController.view fadeIn:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypeFall){
		
		[currentViewController.view fallIn:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypePop){
		
		[currentViewController.view popIn:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypeSlideWithBounce){
		
		[currentViewController.view backInFrom:self.animationDirection inView:self.view withFade:NO duration:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypePush){
		
		int direction = self.animationDirection;
		
		direction += 2;
		
		direction = direction % 4;
		
		
		[self.previousViewController.view slideOutTo:direction inView:self.view duration:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
		[currentViewController.view slideInFrom:self.animationDirection inView:self.view duration:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypePushWithBounce){
		
		int direction = self.animationDirection;
		
		direction += 2;
		
		direction = direction % 4;
		
		[self.previousViewController.view slideOutTo:direction inView:self.view duration:(self.animationDuration*.7) delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		[currentViewController.view backInFrom:self.animationDirection inView:self.view withFade:NO duration:self.animationDuration delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];
		
	}else if(self.animationType == FJSAnimationTypeReveal){
		
		currentViewController.view.hidden = NO;

		[self.view bringSubviewToFront:self.previousViewController.view];
		[self.previousViewController.view slideOutTo:self.animationDirection inView:self.view duration:(self.animationDuration*.7) delegate:self startSelector:@selector(animationDidStart:) stopSelector:@selector(animationDidStop:finished:)];		
	}
}


- (void)animationDidStart:(CAAnimation*)animation{
	
	animationCounter++;
	
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

	animationCounter--;
	
	if(animationCounter < 1){
		
		//Animation finished
		self.isTransitioning = NO;
		self.isAnimating = NO;
		
        [[self nextRunloopProxy] didShowViewController];

	}
}



+ (FJSTransitionController*)transitionControllerForViewController:(UIViewController*)controller{
	
	return [_controllers objectForKey:[NSString stringWithFormat:@"%i", [controller hash]]];

	
}




@end
