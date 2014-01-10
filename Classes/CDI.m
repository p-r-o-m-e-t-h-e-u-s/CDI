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

#import "CDI.h"

#import <objc/runtime.h>
#import "UIStoryboard+CDI.h"

@implementation CDI

#pragma mark Objective-C Integration

/**
* This list contains all classes which will not be injected with interceptors.
*/
static NSMutableArray *interceptorClassFilter = nil;

+ (id)performInstanceInitializationWithInterceptors:(id)reference {
    return [CDI performInstanceInitializationWithInterceptors:reference ignoreFilter:NO];
}

+ (id)performInstanceInitializationWithInterceptors:(id)reference ignoreFilter:(BOOL)ignoreInterceptorFilter {

    // Some classes do special things while initialization.
    if (ignoreInterceptorFilter || ![interceptorClassFilter containsObject:[reference class]]) {

        NSMutableArray *interceptors = nil;

        unsigned int methodIndex = 0;

        Method *methods = class_copyMethodList([reference class], &methodIndex);

        if (methods) {
            while (methodIndex--) {

                NSString *methodName = [NSString stringWithUTF8String:sel_getName(method_getName((methods[methodIndex])))];

                // Check for interception injection
                // -------------------------------------
                if ([methodName hasPrefix:__INJECT_INTERCEPTOR]) {

                    if (!interceptors) interceptors = [[NSMutableArray alloc] init];
                    // Get the interceptor class name which is encoded in the method name
                    NSString *interceptorClassName = [methodName substringFromIndex:[__INJECT_INTERCEPTOR length]];

                    id interceptorClass = [[CDIInjector sharedInstance] getClassForType:interceptorClassName];
                    // Create interceptor instance and add it to the beginning of the chain
                    id interceptorInstance = [[interceptorClass alloc] init];
                    [interceptors insertObject:interceptorInstance atIndex:0];
                }
            }
            free((void *) methods);
        }

        // Process the interceptor injections
        if (interceptors) {
            // Some classes do special things while initialization.
            reference = [[CDIInterceptorProxy alloc] initWithTarget:reference];
            [reference setInterceptors:interceptors];
        }
    }

    return reference;
}

+ (id)performInstanceInitializationWithInjectors:(id)reference {

    unsigned int methodIndex = 0;

    Method *methods = class_copyMethodList([reference class], &methodIndex);

    if (methods) {
        while (methodIndex--) {

            NSString *methodName = [NSString stringWithUTF8String:sel_getName(method_getName((methods[methodIndex])))];
            // Check for instance variable injection
            // -------------------------------------
            if ([methodName hasPrefix:__INJECT_INSTANCE_PREFIX]) {
                // Remove the prefix and use it as the instance variable
                NSString *instanceVariableName = [methodName substringFromIndex:[__INJECT_INSTANCE_PREFIX length]];
                if ([instanceVariableName hasPrefix:__INJECT_TYPE_PREFIX]) {
                    // In this case there is no assignment for a class which should be
                    // instantiated.
                    instanceVariableName = [instanceVariableName substringFromIndex:[__INJECT_TYPE_PREFIX length]];
                    [[CDIInjector sharedInstance] createInstance:instanceVariableName inObject:reference];
                } else {
                    // Extract the type and instance variable name
                    NSUInteger prefixLocation = [instanceVariableName rangeOfString:__INJECT_TYPE_PREFIX].location;
                    NSString *type = [instanceVariableName substringToIndex:prefixLocation];
                    instanceVariableName = [instanceVariableName substringFromIndex:[__INJECT_TYPE_PREFIX length] + prefixLocation];
                    // A class was defined as the type for the variable instantiation.
                    [[CDIInjector sharedInstance] createInstance:instanceVariableName inObject:reference ofType:type];
                }
            }
        }
        free((void *) methods);
    }

    return reference;
}

/**
* The new init method for NSObject.
*
* @return A reference containing injected instance variables and interceptors.
*/
- (id)initCDI {
    self = [CDI performInstanceInitializationWithInjectors:self];
    self = [self initCDI];
    self = [CDI performInstanceInitializationWithInterceptors:self];
    return self;
}

/**
* Swap the implementation of the [NSObject init] with [CDI initCDI].
*/
+ (void)swapInit {

    Method initMethod = class_getInstanceMethod([NSObject class], @selector(init));
    Method initCDIMethod = class_getInstanceMethod([CDI class], @selector(initCDI));
    if (class_addMethod([NSObject class], @selector(initCDI), method_getImplementation(initMethod), method_getTypeEncoding(initMethod))) {
        method_exchangeImplementations(initMethod, initCDIMethod);
    }

    [UIStoryboard swapInit];

}

+ (void)addInterceptorClassFilter:(Class)aClass {
    @synchronized (self) {
        [interceptorClassFilter addObject:aClass];
    }
}

+ (void)initialize {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        interceptorClassFilter = [[NSMutableArray alloc] init];
        [CDI swapInit];
    });
}

@end