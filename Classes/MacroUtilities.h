/*********************************************************************
 *  \file MacroUtilities.h
 *  \author Kailoa Kadano
 *  \date 2006/3/23
 *  \brief Part of TouchSampleCode
 *  \details
 *
 *  \abstract Miscellaneous convenience and utility macros and inline funcitons
 *  \copyright Copyright 2006-2009 6Tringle LLC. All rights reserved.
 */



#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_OS_4_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
#define IS_OS_32_OR_LATER   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2)


#define NSYES [NSNumber numberWithBool:YES]
#define NSNO [NSNumber numberWithBool:NO]

#define ASSERT_TRUE_OR_LOG(condition, ...) do { if (!(condition)) { ALog(__VA_ARGS__); }} while(0)
#define errorLog(object)    (NSLog(@"" @"%s:" #object @"Error! %@", __PRETTY_FUNCTION__, [object description]));


#if DEBUG==1

#define extendedDebugLog(format, ...)

#elif DEBUG==2

#define extendedDebugLog(format, ...) NSLog(@"%s:%@", __PRETTY_FUNCTION__,[NSString stringWithFormat:format, ## __VA_ARGS__]);

#endif


#ifdef DEBUG

#define debugLog(format, ...) NSLog(@"%s:%@", __PRETTY_FUNCTION__,[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define MARK	debugLog(@"%s", __PRETTY_FUNCTION__);
#define START_TIMER NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define END_TIMER(msg) 	NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; debugLog([NSString stringWithFormat:@"%@ Time = %f", msg, stop-start]);


#define DLOG(object)    (NSLog(@"" #object @" %d",object ));
#define FLOG(object)    (NSLog(@"" #object @" %f",object ));
#define OBJECT_LOG(object)    (NSLog(@"" @"%s:" #object @" %@", __PRETTY_FUNCTION__, [object description]));

#define POINTLOG(point)    (NSLog(@""  #point @" x:%f y:%f", point.x, point.y ));
#define SIZELOG(size)    (NSLog(@""  #size @" width:%f height:%f", size.width, size.height ));
#define RECTLOG(rect)    (NSLog(@""  #rect @" x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ));

#define SELECTOR_LOG    (NSLog(@"%@ in %s", NSStringFromSelector(_cmd), __FILE__));
#define METHOD_LOG    (NSLog(@"%@ %s\n%@", NSStringFromSelector(_cmd), __FILE__, self))
#define METHOD_LOG_THREAD    (NSLog(@"%@ %@ %s\n%@", NSStringFromSelector(_cmd), [NSThread currentThread], __FILE__, self))


#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#define NOT_NIL_ASSERT(x)    NSAssert4((x != nil), @"\n\n    ****  Unexpected Nil Assertion  ****\n    ****  " #x @" is nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define NIL_ASSERT(x)    NSAssert4((x == nil), @"\n\n    ****  Unexpected Non-Nil Assertion  ****\n    ****  " #x @" is non-nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ALWAYS_ASSERT    NSAssert4(0, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define MSG_ASSERT(x)    NSAssert5(0, @"\n\n    ****  Unexpected Assertion  **** \nReason: %@\nAssertion in file:%s at line %i in Method %@ with object:\n %@", x, __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define ASSERT_TRUE(test)    NSAssert4(test, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#define MSG_ASSERT_TRUE(test, msg)    NSAssert5(test, @"\n\n    ****  Unexpected Assertion  **** \nReason: %@\nAssertion in file:%s at line %i in Method %@ with object:\n %@", msg, __FILE__, __LINE__, NSStringFromSelector(_cmd), self)



#else

#define extendedDebugLog(format, ...)
#define debugLog(format, ...)
#define MARK
#define START_TIMER
#define END_TIMER(msg)


#define DLOG(object)    
#define FLOG(object)   
#define OBJECT_LOG(object)   

#define POINTLOG(point)    
#define SIZELOG(size)   
#define RECTLOG(rect)   

#define SELECTOR_LOG  
#define METHOD_LOG    
#define METHOD_LOG_THREAD    

#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define NOT_NIL_ASSERT(x)
#define NIL_ASSERT(x)
#define ALWAYS_ASSERT    
#define MSG_ASSERT(x)   
#define ASSERT_TRUE(test)    
#define MSG_ASSERT_TRUE(test, msg) 


#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif

#endif

