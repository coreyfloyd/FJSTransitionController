#import "DrawerController.h"

#define kCloseButtonSize 30
#define kCloseButtonMargin 5
#define kAnimationDuration 0.5


@interface DrawerController ()
@property (nonatomic, readwrite, retain) UIViewController *viewController;
@property (nonatomic, readwrite, assign) BOOL isCollapsed;
@property (nonatomic, retain) UIButton *closeButton;
@end

@implementation DrawerController

@synthesize viewController;
@synthesize collapseMode;
@synthesize isCollapsed;
@synthesize frame;
@synthesize closeButtonLocation;
@synthesize closeButton;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithFrame:(CGRect)aframe;
{
	self = [super init];
	if (self != nil) {
		frame = aframe;
		isCollapsed = YES;
	}
	return self;
}



- (void)dealloc {
	[closeButton release], closeButton = nil;
	[viewController release], viewController = nil;;
    [super dealloc];
}

- (CGPoint) centerPointForCloseButton{

	if( self.closeButtonLocation == DrawerControllerCloseButtonTopLeft )
		return CGPointMake(kCloseButtonSize/2 + kCloseButtonMargin,
						   kCloseButtonSize/2 + kCloseButtonMargin);
	
	else if( self.closeButtonLocation == DrawerControllerCloseButtonTopRight )
		return CGPointMake(self.view.bounds.size.width - (kCloseButtonSize/2 + kCloseButtonMargin),
						   kCloseButtonSize/2 + kCloseButtonMargin);
	
	else if( self.closeButtonLocation == DrawerControllerCloseButtonBottomRight )
		return CGPointMake(self.view.bounds.size.width - (kCloseButtonSize/2 + kCloseButtonMargin),
						   self.view.bounds.size.height - (kCloseButtonSize/2 + kCloseButtonMargin));
	
	else if( self.closeButtonLocation == DrawerControllerCloseButtonBottomLeft )
		return CGPointMake(kCloseButtonSize/2 + kCloseButtonMargin,
						   self.view.bounds.size.height - (kCloseButtonSize/2 + kCloseButtonMargin));
	
	// return something weird for the default
	return self.view.center;
}


- (void)loadView {
	UIView *containerView = [[UIView alloc] initWithFrame:self.frame];
	containerView.userInteractionEnabled = NO;
	containerView.clipsToBounds = YES;
	self.view = containerView;
	[containerView release];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake( 0, 0, kCloseButtonSize, kCloseButtonSize );		
	button.center = [self centerPointForCloseButton];
	button.enabled = NO;
	button.alpha = 0.0;
	[button setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(collapseAnimated:) forControlEvents:UIControlEventTouchUpInside];
	self.closeButton = button;
	[self.view addSubview:self.closeButton];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) expandWithViewController:(UIViewController *)vc animated:(BOOL)animated {
	
	if( !self.isCollapsed )
		return;

	self.viewController = vc;
	[self.view addSubview:self.viewController.view];
	
	if( animated ) {
		
		CGRect startFrame = self.view.bounds;
		
		if( self.collapseMode == DrawerControllerCollapseTop ) {
			startFrame.origin.y -= startFrame.size.height;
		} else {
			startFrame.origin.y += startFrame.size.height;			
		}
		
		self.viewController.view.frame = startFrame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];
	}

	self.viewController.view.frame = self.view.bounds;

	if( animated ) {
		[UIView commitAnimations];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];
	}		
	
	[self.view bringSubviewToFront:self.closeButton];
	self.closeButton.enabled = YES;
	self.closeButton.alpha = 1.0;
	
	if( animated ) {
		[UIView commitAnimations];
	}
	
	self.isCollapsed = NO;
}

- (IBAction) collapseAnimated:(id)sender
{
	[self collapse:YES];
}


- (void) collapse:(BOOL)animated {
	
	if( self.isCollapsed )
		return;
	
	if( animated ) {
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:kAnimationDuration];

	}

	CGRect newFrame = self.viewController.view.frame;
	if( self.collapseMode == DrawerControllerCollapseTop ) {
		newFrame.origin.y -= newFrame.size.height;
	} else {
		newFrame.origin.y += newFrame.size.height;			
	}
	
	self.viewController.view.frame = newFrame;

	if( animated ) {
		[UIView commitAnimations];
	}		
	
	self.closeButton.alpha = 0.0;
	self.closeButton.enabled = NO;
	
	self.isCollapsed = YES;
}	



@end
