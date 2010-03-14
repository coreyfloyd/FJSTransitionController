//
//  FJSKeyedViewControllerAppDelegate.h
//  FJSKeyedViewController
//
//  Created by Corey Floyd on 3/12/10.
//  Copyright Flying Jalapeño Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FJSTransitionController;

@interface FJSKeyedViewControllerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FJSTransitionController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FJSTransitionController *viewController;

@end

