//
//  SDNextRunloopProxy.h
//  CocoaTest
//
//  Created by Steven Degutis on 7/31/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SDNextRunloopProxy : NSObject {
	id target;
	NSInvocation *invocation;
}

@end

@interface NSObject (SDStuff)
- (id) nextRunloopProxy;
@end
