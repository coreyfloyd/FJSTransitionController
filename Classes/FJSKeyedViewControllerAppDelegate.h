//
//  FJSKeyedViewControllerAppDelegate.h
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FJSKeyedViewController;

@interface FJSKeyedViewControllerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FJSKeyedViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FJSKeyedViewController *viewController;

@end

