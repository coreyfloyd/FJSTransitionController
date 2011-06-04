
#import "FJTransitionController.h"
#import "NSObject+Proxy.h"
#import <objc/runtime.h>


//The following function borows heavily from FTUtils
//Thanks for the inspiration!

void setViewControllerCenterPoint(FJPosition position, UIViewController* viewcontroller){
    
    CGPoint viewCenter = CGPointMake(CGRectGetMidX(viewcontroller.view.frame), 
                                     CGRectGetMidY(viewcontroller.view.frame));
    CGRect viewFrame = viewcontroller.view.frame;
    CGRect enclosingViewFrame = viewcontroller.transitionController.view.bounds;
    
    CGPoint offScreenPoint = CGPointZero;
    
    switch (position) {
        case FJPositionCenter: {
            
            CGPoint containerCenter = CGPointMake(CGRectGetMidX(enclosingViewFrame), 
                                             CGRectGetMidY(enclosingViewFrame));
			offScreenPoint = containerCenter;
			break;
		}
		case FJPositionOffScreenBottom: {
			CGFloat extraOffset = viewFrame.size.height / 2;
			offScreenPoint = CGPointMake(viewCenter.x, enclosingViewFrame.size.height + extraOffset);
			break;
		}
		case FJPositionOffScreenTop: {
			CGFloat extraOffset = viewFrame.size.height / 2;
			offScreenPoint = CGPointMake(viewCenter.x, enclosingViewFrame.origin.y - extraOffset);
			break;
		}
		case FJPositionOffScreenLeft: {
			CGFloat extraOffset = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.origin.x - extraOffset, viewCenter.y);
			break;
		}
		case FJPositionOffScreenRight: {
			CGFloat extraOffset = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.size.width + extraOffset, viewCenter.y);
			break;
		}
		case FJPositionOffScreenBottomLeft: {
			CGFloat extraOffsetHeight = viewFrame.size.height / 2;
			CGFloat extraOffsetWidth = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
			break;
		}
		case FJPositionOffScreenTopLeft: {
			CGFloat extraOffsetHeight = viewFrame.size.height / 2;
			CGFloat extraOffsetWidth = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.origin.x - extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
			break;
		}
		case FJPositionOffScreenBottomRight: {
			CGFloat extraOffsetHeight = viewFrame.size.height / 2;
			CGFloat extraOffsetWidth = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.size.height + extraOffsetHeight);
			break;
		}
		case FJPositionOffScreenTopRight: {
			CGFloat extraOffsetHeight = viewFrame.size.height / 2;
			CGFloat extraOffsetWidth = viewFrame.size.width / 2;
			offScreenPoint = CGPointMake(enclosingViewFrame.size.width + extraOffsetWidth, enclosingViewFrame.origin.y - extraOffsetHeight);
			break;
		}
	}

    viewcontroller.view.center = offScreenPoint;
}



static NSMutableDictionary* _controllers = nil;

@interface UIViewController (SetFJTransitionController)

- (void)setTransitionController:(FJTransitionController*)transitionController;

@end


@implementation UIViewController (SetFJTransitionController)

- (void)setTransitionController:(FJTransitionController*)transitionController{
	
	[_controllers setObject:transitionController forKey:[NSString stringWithFormat:@"%i", [self hash]]];
	
}

@end


@implementation UIViewController (FJTransitionController)

- (FJTransitionController*)transitionController{
	
	return [_controllers objectForKey:[NSString stringWithFormat:@"%i", [self hash]]];
}

@end


@interface UINavigationController (FJTransitionController)

- (UIViewController*)rootViewController;

@end


@implementation UINavigationController (FJTransitionController)


- (UIViewController*)rootViewController{
    
    if([[self viewControllers] count] == 0)
        return nil;
    
    return [[self viewControllers] objectAtIndex:0];

}

@end


@interface FJTransitionControllerMetaData : NSObject {
    
    NSString* key;
    
    Class class;
    NSString* nibName;
    NSBundle* bundle;
    
    BOOL shouldUseNavigationController;

    UIViewController* viewController;
    UINavigationController* navigationController;
    
        
}
@property (nonatomic, copy) NSString *key;
@property (nonatomic) Class class;
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic) BOOL shouldUseNavigationController;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (UIViewController*)viewControllerToDisplay;

@end


@implementation FJTransitionControllerMetaData

@synthesize key;
@synthesize class;
@synthesize nibName;
@synthesize bundle;
@synthesize shouldUseNavigationController;
@synthesize viewController;
@synthesize navigationController;


- (void)dealloc {
    
    [key release];
    key = nil;
    [nibName release];
    nibName = nil;
    [bundle release];
    bundle = nil;
    [viewController release];
    viewController = nil;
    [super dealloc];
    
}


- (UIViewController*)viewController{
    
    if(viewController != nil)
        return viewController;

    UIViewController* controller = nil;
			
	if(self.nibName == nil){
		
		controller = [[self.class alloc] init];
		
	}else{
				
		controller = [[self.class alloc] initWithNibName:self.nibName bundle:self.bundle];
	}
    
    [self setViewController:controller];
    [controller release];
    	        
    if(self.shouldUseNavigationController && ![controller isKindOfClass:[UINavigationController class]]){
        
        UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.navigationController = nc;
        [nc release];
    }
    
	return viewController;

}

- (UIViewController*)viewControllerToDisplay{
    
    UIViewController* vc = [self viewController];
    
    if(self.navigationController != nil)
        return self.navigationController;
    
    return vc;
    
}

@end


@interface FJTransitionController ()

@property(nonatomic,retain)NSMutableDictionary *controllerData;

@property (nonatomic,readwrite,retain)NSArray *viewControllerKeyHistory;

@property(nonatomic,assign,readwrite)BOOL isTransitioning;

- (void)_addToViewControllerKeyHistory:(NSString*)viewControllerKey;


//access
- (void)_setViewControllerMetaData:(FJTransitionControllerMetaData *)metaData forKey:(NSString *)key;
- (FJTransitionControllerMetaData*)_metaDataForKey:(NSString*)key;
- (void)_removeMetaDataForKey:(NSString *)key;

@end

@implementation FJTransitionController

@synthesize controllerData;
@synthesize viewControllerKeyHistory;
@synthesize isTransitioning;
@synthesize delegate;


+ (void)load{
        
    _controllers = [[NSMutableDictionary alloc] init];

}


#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    delegate = nil;
    [viewControllerKeyHistory release];
    viewControllerKeyHistory = nil;
	[controllerData release]; 
    controllerData = nil;
    [super dealloc];
}

#pragma -
#pragma mark UIViewController


- (id)init {
    self = [super init];
    if (self) {
        self.controllerData = [NSMutableDictionary dictionary];
        self.viewControllerKeyHistory = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.controllerData = [NSMutableDictionary dictionary];
        self.viewControllerKeyHistory = [NSMutableArray array];
    }
    return self;
}


#pragma mark -
#pragma mark View Life Cycle


- (void)viewDidLoad{
	[super viewDidLoad];    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.activeViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self.activeViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self.activeViewController viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self.activeViewController viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    
    [self deallocateAllInactiveViewControllers];
    
	//TODO: any other cleanup?
	
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload{
	
    [self deallocateAllInactiveViewControllers];
    
    [self.activeViewController viewDidUnload];
    
	//TODO: any other cleanup?
    
    [super viewDidUnload];
    
}


#pragma mark -
#pragma mark History

- (void)_addToViewControllerKeyHistory:(NSString*)viewControllerKey
{
    [viewControllerKeyHistory insertObject:viewControllerKey atIndex:0];
}

- (NSString*)_viewControllerKeyAtIndex:(NSUInteger)index{
    
    if([[self viewControllerKeyHistory] count] <= index)
        return nil;
    
    return [[self viewControllerKeyHistory] objectAtIndex:index];
}


#pragma mark -
#pragma mark Controller Data Dictionary

- (FJTransitionControllerMetaData*)_metaDataForKey:(NSString*)key{
    
    if(key == nil)
        return nil;
    
    return [self.controllerData objectForKey:key];
    
}

- (void)_setViewControllerMetaData:(FJTransitionControllerMetaData *)metaData forKey:(NSString *)key{
    
    if(key == nil || metaData == nil)
        return;
    
    [self.controllerData setObject:metaData forKey:key];
    
}

- (void)_removeMetaDataForKey:(NSString *)key{
    
    if(key == nil)
        return;
    
    [self.controllerData removeObjectForKey:key];    
}



#pragma mark -
#pragma mark Accessors


- (NSArray*)allKeys{
	
	return [self.controllerData allKeys];
	
}

- (UIViewController*)viewControllerForKey:(NSString*)key{
    
    FJTransitionControllerMetaData* metadata = [self _metaDataForKey:key];

    UIViewController* vc = metadata.viewController;
    
	return vc;
}

- (UIViewController*)activeViewController{
    
    return [self viewControllerForKey:[self activeViewControllerKey]];
    
}

- (NSString*)activeViewControllerKey{
    
    return [self _viewControllerKeyAtIndex:0];
    
}

- (UIViewController*)lastViewController{
    
    return [self viewControllerForKey:[self lastViewControllerKey]];
    
}

- (NSString*)lastViewControllerKey{
    
    return [self _viewControllerKeyAtIndex:1];
    
}


#pragma mark -
#pragma mark Add VC

- (void)setViewController:(UIViewController*)controller forKey:(NSString*)key{
	
    if(controller == nil || key == nil){
     
        ALWAYS_ASSERT;
    }
    
    if([[self activeViewControllerKey] isEqualToString:key])
		return;
    
    FJTransitionControllerMetaData* metadata = [[FJTransitionControllerMetaData alloc] init];
    metadata.viewController = controller;
    metadata.key = key;
    	
    [self _setViewControllerMetaData:metadata forKey:key];
    [metadata release];
	
	
}

- (void)setViewControllerWithClass:(Class)viewControllerClass forKey:(NSString*)key withNavigationController:(BOOL)useNavigationController{
        	
    [self setViewControllerWithClass:viewControllerClass nib:nil bundle:nil forKey:key withNavigationController:useNavigationController];

}

//This one is the same, but you ca point to a nib as well
- (void)setViewControllerWithClass:(Class)viewControllerClass nib:(NSString*)nibName bundle:(NSBundle*)bundle forKey:(NSString*)key withNavigationController:(BOOL)useNavigationController{
	
    if(!viewControllerClass || key == nil){
        
        ALWAYS_ASSERT;
    }
    
	if([self.activeViewControllerKey isEqualToString:key])
		return;
    
    FJTransitionControllerMetaData* metadata = [[FJTransitionControllerMetaData alloc] init];
    metadata.class = viewControllerClass;
    metadata.nibName = nibName;
    metadata.bundle = bundle;
    metadata.key = key;
	
    [self _setViewControllerMetaData:metadata forKey:key];
    [metadata release];
    
}



#pragma mark -
#pragma mark Load VC

- (UIViewController*)loadViewControllerForKey:(NSString*)key{
    
    if(isTransitioning)
        return nil;
    
    if(key == nil)
        return nil;
    
    if([key isEqualToString:self.activeViewControllerKey]){
        
        return [self viewControllerForKey:key];

    }
    
    FJTransitionControllerMetaData* metadata = [self _metaDataForKey:key];
    UIViewController* vc = metadata.viewController;
    UIViewController* viewControllerToDisplay = [metadata viewControllerToDisplay];
    
    if(vc == nil){
        
        ALWAYS_ASSERT;

    }
    
    [vc setTransitionController:self];
    [viewControllerToDisplay setTransitionController:self]; //just in case it is a nav
    [self _addToViewControllerKeyHistory:key];
    
    FJTransitionControllerMetaData* lastMetadata = [self _metaDataForKey:self.lastViewControllerKey];
    //UIViewController* lastVC = lastMetadata.viewController;
    UIViewController* viewControllerToRemove = [lastMetadata viewControllerToDisplay];
    
    //Lock Transition Controller
    self.isTransitioning = YES;
    
    [viewControllerToDisplay.view setFrame:self.view.bounds];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
       
        viewControllerToDisplay.view.userInteractionEnabled = NO;
        viewControllerToRemove.view.userInteractionEnabled = NO;
        
        if([self.delegate respondsToSelector:@selector(transitionController:willLoadViewController:animated:)])
            [self.delegate transitionController:self willLoadViewController:viewControllerToDisplay animated:NO];

        [self.view addSubview:viewControllerToDisplay.view];            

        [viewControllerToDisplay viewWillAppear:YES];
        [viewControllerToRemove viewWillDisappear:YES];

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [viewControllerToRemove viewDidDisappear:YES];
            [viewControllerToDisplay viewDidAppear:YES];
            
            //Unlock Transition Controller
            self.isTransitioning = NO;
            
            if([self.delegate respondsToSelector:@selector(transitionController:didLoadViewController:animated:)])
                [self.delegate transitionController:self didLoadViewController:viewControllerToDisplay animated:NO];
            
            viewControllerToDisplay.view.userInteractionEnabled = YES;
            viewControllerToRemove.view.userInteractionEnabled = YES;
            [viewControllerToRemove.view removeFromSuperview];
            
        });

        
    });
    
	return vc;
    
}

//Now it gets fun. Specify animations for each view controller
- (void)loadViewControllerForKey:(NSString*)key
              appearingViewOnTop:(BOOL)viewOnTop //some animations need the new view on top
                      setupBlock:(void (^)(UIViewController* appearingViewController))setupBlock //start hidden or offscreen?
     appearingViewAnimationBlock:(void (^)(UIViewController* appearingViewController))appearingViewAnimationBlock
  disappearingViewAnimationBlock:(void (^)(UIViewController* disappearingViewController))disappearingViewAnimationBlock{    
    
    if(isTransitioning)
        return;
    
    if(key == nil)
        return;
    
    if([key isEqualToString:self.activeViewControllerKey]){
        
        return;
        
    }
    
    FJTransitionControllerMetaData* metadata = [self _metaDataForKey:key];
    UIViewController* vc = metadata.viewController;
    UIViewController* viewControllerToDisplay = [metadata viewControllerToDisplay];
    
    if(vc == nil){
        
        ALWAYS_ASSERT;
        
    }
    
    [vc setTransitionController:self];
    [viewControllerToDisplay setTransitionController:self]; //just in case it is a nav
    [self _addToViewControllerKeyHistory:key];
    
    FJTransitionControllerMetaData* lastMetadata = [self _metaDataForKey:self.lastViewControllerKey];
    //UIViewController* lastVC = lastMetadata.viewController;
    UIViewController* viewControllerToRemove = [lastMetadata viewControllerToDisplay];
    
    //Lock Transition Controller
    self.isTransitioning = YES;

    [viewControllerToDisplay.view setFrame:self.view.bounds];
    setupBlock(viewControllerToDisplay);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        viewControllerToDisplay.view.userInteractionEnabled = NO;
        viewControllerToRemove.view.userInteractionEnabled = NO;
        
        if([self.delegate respondsToSelector:@selector(transitionController:willLoadViewController:animated:)])
            [self.delegate transitionController:self willLoadViewController:viewControllerToDisplay animated:YES];
        
        if(!viewOnTop && viewControllerToRemove)
            [self.view insertSubview:viewControllerToDisplay.view belowSubview:viewControllerToRemove.view];
        else
            [self.view addSubview:viewControllerToDisplay.view];       
        
        [viewControllerToDisplay viewWillAppear:YES];
        [viewControllerToRemove viewWillDisappear:YES];

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [viewControllerToRemove viewDidDisappear:YES];
            [viewControllerToDisplay viewDidAppear:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [UIView animateWithDuration:0.75 
                                      delay:0.0 
                                    options:0 
                                 animations:^(void) {
                                     
                                     appearingViewAnimationBlock(viewControllerToDisplay);
                                     disappearingViewAnimationBlock(viewControllerToRemove);
                                     
                                 } completion:^(BOOL finished) {
                                     
                                     //Unlock Transition Controller
                                     self.isTransitioning = NO;
                                     
                                     if([self.delegate respondsToSelector:@selector(transitionController:didLoadViewController:animated:)])
                                         [self.delegate transitionController:self didLoadViewController:viewControllerToDisplay animated:NO];
                                     
                                     viewControllerToDisplay.view.userInteractionEnabled = YES;
                                     viewControllerToRemove.view.userInteractionEnabled = YES;
                                     [viewControllerToRemove.view removeFromSuperview];
                                     
                                 }];
                
                
            });
            
        });
        
    });
    
}

#pragma mark -
#pragma mark Cleanup


- (void)removeViewControllerForKey:(NSString*)key{
	
	[self _removeMetaDataForKey:key];
	
}

- (void)releaseViewControllerForKey:(NSString*)key{
    
    FJTransitionControllerMetaData* meta = [self _metaDataForKey:key];
    meta.viewController = nil;
    
}

- (void)deallocateAllInactiveViewControllers{
    
    NSArray *keys = [self allKeys];
	for(NSString* eachKey in keys){
        
		//if a vc is offscreen, kill it. I am ruthless
		if(eachKey != self.activeViewControllerKey){
			
            [self releaseViewControllerForKey:eachKey]; //poof!
			
		}
	}    
}






@end
