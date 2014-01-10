//
//    The MIT License (MIT)
//
//    Copyright (c) 2013 real-prometheus <real.prometheus@gmail.com>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//    the Software, and to permit persons to whom the Software is furnished to do so,
//    subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#define __INJECT_INTERCEPTOR @"__INJECT_INTERCEPTOR__"


/**
* Define the injection of the interceptor.
*
* Use:
* @intercept(name,interceptor)
*/
#define intercept(name,interceptor) interface name (ContextAndDependencyInjectionInterceptor_ ## interceptor)\
@property (nonatomic, readonly) interceptor * __INJECT_INTERCEPTOR__ ## interceptor;\
@end\
@implementation name (ContextAndDependencyInjectionInterceptor_ ## interceptor)\
@dynamic __INJECT_INTERCEPTOR__ ## interceptor;\
-( interceptor * ) __INJECT_INTERCEPTOR__ ## interceptor {\
    return nil;\
}\
@end\

@class CDIInterceptor;

/**
* The CDIInvocationContext provides all data which is used in the interceptors.
*/
@interface CDIInvocationContext : NSObject {
}

/**
* The target / instance of the method call.
*/
@property(nonatomic, readonly) id target;

/**
* The selector of the method call.
*/
@property(nonatomic, readonly) SEL selector;

/**
* The name of the selector of the method call.
*/
@property(nonatomic, readonly) NSString *method;

/**
 * Initialize the invocation context with the invocation and a list of all interceptors in the chain.
 */
- (id)initWithInvocation:(NSInvocation *)anInvocation andInterceptors:(NSArray *)interceptors;

/**
 * Execute the method or call another interceptor in the chain.
 */
- (void)execute;

@end

/**
* An interceptor has to extend CDIInterceptor and can be injected with @interceptor(MyClass,MyInterceptor).
*/
@interface CDIInterceptor : NSObject
/**
 * Invoke is called for any registered interceptor for method call.
 */
- (void)invoke:(CDIInvocationContext *)context;
@end

/**
* A proxy will be created whenever a interceptors are used.
*/
@interface CDIInterceptorProxy : NSProxy

/**
* A list with a all interceptors which will called before the the method execution.
*/
@property(nonatomic, retain) NSArray *interceptors;

/**
* Initialize with the reference which will be replaced by this proxy.
*/
- (id)initWithTarget:(id)aTarget;

@end
