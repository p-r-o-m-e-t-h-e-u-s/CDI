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
#define __INJECT_METHOD @"__INJECT_METHOD__"

/**
 * TODO
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
 * TODO
 */
@interface CDIInvocationContext : NSObject {
}

@property(nonatomic, readonly) id target;
@property(nonatomic, readonly) SEL selector;
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

@interface CDIInterceptor : NSObject
/**
 * Invoke is called for any registred interceptor for method call
 */
- (void)invoke:(CDIInvocationContext *)context;
@end

@interface CDIInterceptorProxy : NSProxy {
}

@property(nonatomic) NSArray *interceptors;

- (id)initWithTarget:(id)aTarget;


@end
