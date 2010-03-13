#import <UIKit/UIKit.h>

typedef enum {
	DrawerControllerCollapseTop = 0, 
	DrawerControllerCollapseBottom = 1, 
} DrawerControllerCollapseMode;

typedef enum {
	DrawerControllerCloseButtonTopLeft = 0, 
	DrawerControllerCloseButtonTopRight = 1,
	DrawerControllerCloseButtonBottomRight = 2,
	DrawerControllerCloseButtonBottomLeft = 3,
} DrawerControllerCloseButtonLocation;



@interface DrawerController : UIViewController {

	CGRect frame;
	DrawerControllerCollapseMode collapseMode;
	DrawerControllerCloseButtonLocation closeButtonLocation;
	UIButton *closeButton;

	UIViewController *viewController;
	BOOL isCollapsed;	
}

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) DrawerControllerCollapseMode collapseMode;
@property (nonatomic, assign) DrawerControllerCloseButtonLocation closeButtonLocation;

- (void) expandWithViewController:(UIViewController *)vc animated:(BOOL)animated;
- (void) collapse:(BOOL)animated;
- (IBAction) collapseAnimated:(id)sender;

@property (nonatomic, readonly, assign) BOOL isCollapsed;
@property (nonatomic, readonly, retain) UIViewController *viewController;

@end
