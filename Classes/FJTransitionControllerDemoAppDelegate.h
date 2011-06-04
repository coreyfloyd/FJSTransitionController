//
//  FJSKeyedViewControllerAppDelegate.h
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FJTransitionController;

@interface FJTransitionControllerDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FJTransitionController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FJTransitionController *viewController;

@end

