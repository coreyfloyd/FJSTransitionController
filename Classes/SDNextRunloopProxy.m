//
//  SDNextRunloopProxy.m
//  CocoaTest
//
//  Created by Steven Degutis on 7/31/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDNextRunloopProxy.h"


@implementation SDNextRunloopProxy

- (id) initWithTarget:(id)newTarget {
	if (self = [super init]) {
		target = [newTarget retain];
	}
	return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	invocation = [anInvocation retain];
	[invocation retainArguments];
	[self performSelector:@selector(performSelectorAtNextRunloop) withObject:nil afterDelay:0.0];
}

- (void) performSelectorAtNextRunloop {
	[invocation invokeWithTarget:target];
	[target release];
	[invocation release];
	[self release];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [target methodSignatureForSelector:aSelector];
}

@end

@implementation NSObject (SDStuff)
- (id) nextRunloopProxy {
	return [[SDNextRunloopProxy alloc] initWithTarget:self];
}
@end
