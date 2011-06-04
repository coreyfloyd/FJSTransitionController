

#FJTransitionController

This class allows you to load view controllers and optionally animate transitions between the views.

Instead of managing a stack (UINavigationController) or an array (UITabBarController) View controllers are keyed in a dictionary. Think of it as a replacement for UINavigationController or UITabBarController.

Transition animations are performed by setting any of the animatable view properties. Optionally these changes can be nested in other animation blocks for fine grain timing and control.

##Setup

Just drop FJTransitionController.h/.m in your project.

Add a property in your AppDelegate:

@property (nonatomic,retain) FJTransitionController* myTransitionController;

And add it to the window:

[window addSubview:myTransitionController.view];


##Basic Use

To set associate a view controller with a key:

FJTransitionController* myTransitionController;  
[myTransitionController setViewControllerClass:[MyVC class] forKey:@"myKey" withNavigationController:YES];

To use a nib:  
[myTransitionController setViewControllerClass:[MyVC class] nib:@"myVC" bundle:nil forKey:@"myKey" withNavigationController:YES];

The "withNavigationController" flag allows you to optionally "wrap" any view controller in a UINavigationController.


To load a VC without animation:  
[myTransitionController loadViewControllerForKey:@"myKey"];


You can access the history of what view controllers have been loaded by checking:

@property (nonatomic,readonly,retain)NSArray *viewControllerKeyHistory;

And there are a few connivence methods as well:

@property (nonatomic,readonly)UIViewController *activeViewController;
@property (nonatomic,readonly)NSString *activeViewControllerKey;
@property (nonatomic,readonly)UIViewController *lastViewController;
@property (nonatomic,readonly)NSString *lastViewControllerKey;



Just like the UITabBarController and UINavigationCOntroller, every UIViewController has a convenience property to access the FJSTransitionController instance it is associated with:

@property(nonatomic, readonly) FJSTransitionController* transitionController;



##Animations
To use animations use the following method:

[self.transitionController loadViewControllerForKey:@"MyVCKey" 
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


Each block passes back the view controller so that the properties can be changes. The first block allows setup like making the opacity 0.0 or moving eh view off screen. The next 2 blocks set the final properties of both the appearing and disappearing view controllers. To find out what you can manipulate, refer to the UIView Class Documentation.

You can use the "setViewControllerCenterPoint" function to quickly set the center point for animations on and off screen.

##Behavior
FJTC sends your VCs all proper viewDid/WillAppear and viewDid/WillDisappear messages WITH proper timing (Just the way that Tab bars and Nav Controllers Work).

Your VC's view have the userInteractionEnabled flag set to NO during animations. Only 1 VC can be loaded at a time. Trying to load another VC while a transition is occurring results in a Nonop.

FJTransitionController also forwards didRecieveMememoryWarning messages to your VCs. Additionally, it cleans up off screen VCs in low memory situations.  
If you have provided the class and nib of a VC, it will also re-instantiate and VCs automatically. (It will be up to you to save any state in VWD/VDD/VDU and dealloc)



