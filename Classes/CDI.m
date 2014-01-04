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

@implementation CDI {
}


#pragma mark Objective-C Integration

/**
 * The initWithInject method is called before the init on any other NSObject creation. It will replace the
 * @inject annotation with an instance and intergarte the interceptors.
 */
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
- (id)initWithInject {
    
        // Now call the init (remember init was renamed to doInject)
    id returnSelf = [self initWithInject];
    
    NSMutableArray *interceptors = nil;
    
        // Avoid unlimited loop - injection will not be available in the CDI implementation itself
    if ([self isKindOfClass:[CDIInjector class]]) {
        return self;
    }
    
    unsigned int methodIndex = 0;
    
    Method *methods = class_copyMethodList([self class], &methodIndex);
    
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
                    [[CDIInjector sharedInstance] createInstance:instanceVariableName inObject:self];
                } else {
                        // Extract the type and instance variable name
                    NSUInteger prefixLocation = [instanceVariableName rangeOfString:__INJECT_TYPE_PREFIX].location;
                    NSString *type = [instanceVariableName substringToIndex:prefixLocation];
                    instanceVariableName = [instanceVariableName substringFromIndex:[__INJECT_TYPE_PREFIX length] + prefixLocation];
                        // A class was defined as the type for the variable instantiation.
                    [[CDIInjector sharedInstance] createInstance:instanceVariableName inObject:self ofType:type];
                }
            }
            
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
        if(![self isKindOfClass:[UIViewController class]]) {
            returnSelf = [[CDIInterceptorProxy alloc] initWithTarget:returnSelf];
            [returnSelf setInterceptors:interceptors];
        }
    }
    
    return returnSelf;
}

#pragma clang diagnostic pop

/**
 * Swap the implementation of the [NSObject init] with [CDIInjector initWithInject].
 */
+ (void)swapInit {

    Method initMethod = class_getInstanceMethod([NSObject class], @selector(init));
    Method doInjectMethod = class_getInstanceMethod([CDI class], @selector(initWithInject));

    if (class_addMethod([NSObject class], @selector(initWithInject), method_getImplementation(initMethod), method_getTypeEncoding(initMethod))) {
        method_exchangeImplementations(initMethod, doInjectMethod);
    }
}

/**
 * Initialize will replace the init implementation of NSObject.
 */
+ (void)initialize {
    if (self == [CDI class]) {
        [CDI swapInit];
    }
}

@end