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

#import "CDIInterceptor.h"
#import <objc/objc-runtime.h>


@implementation CDIInvocationContext {

    /**
     * The original invocation provided by the proxy implementation.
     */
    NSInvocation *invocation;

    /**
     * TODO
     */
    NSArray *interceptors;

    long count;
}

@dynamic target, selector, method;

/**
 * Initialize the invocation context with the invocation and a list of all interceptors in the chain.
 */
- (id)initWithInvocation:(NSInvocation *)anInvocation andInterceptors:(NSArray *)allInterceptors {
    if (self = [super init]) {
        invocation = anInvocation;
        interceptors = allInterceptors;
        count = 0;
    }
    return self;
}

- (id)target {
    return invocation.target;
}

- (SEL)selector {
    return invocation.selector;
}

- (NSString *)method {
    return [NSString stringWithUTF8String:sel_getName(self.selector)];
}

/**
 * Execute the method or call another interceptor in the chain.
 */
- (void)execute {
    if ([interceptors count] > count) {
        CDIInterceptor *nextInterceptor = [interceptors objectAtIndex:count++];
        [nextInterceptor invoke:self];
    } else {
        [invocation invoke];
    }
}
@end

@implementation CDIInterceptor {
}

- (void)invoke:(CDIInvocationContext *)context {
}

@end


// MessageInterceptor.m
@implementation CDIInterceptorProxy {
    id target;
}

@synthesize interceptors;

- (id)initWithTarget:(id)aTarget {
    target = aTarget;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
    if (signature == nil) {
        signature = [super methodSignatureForSelector:sel];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [target respondsToSelector:aSelector] ? YES : [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
//    SEL aSelector = [invocation selector];
//    (void)aSelector;
    invocation.target = target;

    // Build the chain of interceptors, which will be executed sequentially
    CDIInvocationContext *context = [[CDIInvocationContext alloc] initWithInvocation:invocation andInterceptors:self.interceptors];
    [context execute];


}

@end
