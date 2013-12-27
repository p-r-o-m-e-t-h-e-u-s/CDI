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

@implementation CDIException
@end

@interface CDI ()
/**
 * Contains all loaded protocols from the runtime environment.
 */
@property(nonatomic, readwrite) NSDictionary *protocolCache;
/**
 * Manual implementation bindings dictionary containing types as keys and
 * the implementation classes as values.
 */
@property(nonatomic, readonly) NSMutableDictionary *implementationBindings;
@end

@implementation CDI

@synthesize protocolCache;

- (void)createInstance:(NSString *)variableName inObject:(id)object {

    // Fetch all ivars for the given class as dictionary
    NSDictionary *ivarDict = [self ivarsFromClass:[object class]];

    // Search for its type and throw an exception if not found
    NSString *variableAsString = [ivarDict objectForKey:variableName];
    if (!variableAsString) [CDIException raise:@"Context and Dependency Injection" format:@"Instance variable %@ not available in class %@", variableName, [object class]];
    // Check whether an id was defined without implementation type
    if ([variableAsString isEqualToString:@"@"]) [CDIException raise:@"Context and Dependency Injection" format:@"No implementation definied for %@ in class %@.", variableName, [object class]];

    // Remove the prefix and suffix to get a clean type
    NSString *type = [variableAsString substringWithRange:NSMakeRange(2, [variableAsString length] - 3)];

    [self createInstance:variableName inObject:object ofType:type];
}

- (void)createInstance:(NSString *)variableName inObject:(id)object ofType:(NSString *)type {
    
    Ivar ivar = class_getInstanceVariable([object class], [variableName UTF8String]);
    // If it already is set, do not override it
    if(!object_getIvar(object, ivar)) {
    
    // Create the instance and assign it to the instance variable
    id instanceVariableClassType = [self getClassForType:type];

    // Classes known as singletons containing a method 'sharedInstance' will be instantiated with this method
    SEL sharedInstanceSelector = NSSelectorFromString(@"sharedInstance");
    Method sharedInstanceMethod = class_getClassMethod([instanceVariableClassType class], sharedInstanceSelector);
    id instanceVariableValue;
    if (sharedInstanceMethod) {
        // Instantiate the singleton
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        instanceVariableValue = [[instanceVariableClassType class] performSelector:sharedInstanceSelector];
#pragma clang diagnostic pop
    } else {
        // Use default instance creation with alloc and init
        instanceVariableValue = [[instanceVariableClassType alloc] init];
    }
        object_setIvar(object, ivar, instanceVariableValue);
    }

}

- (void)bindClass:(Class)instanceVaiableClassType with:(Class)implementationClass {
    if (![implementationClass isSubclassOfClass:instanceVaiableClassType]) [CDIException raise:@"Context and Dependency Injection" format:@"Class binding exception - %@ is not a subclass of %@.", implementationClass, NSStringFromClass(instanceVaiableClassType)];
    [self.implementationBindings setObject:implementationClass forKey:NSStringFromClass(instanceVaiableClassType)];
}

- (void)bindProtocol:(Protocol *)instanceVaiableProtocolType with:(Class)implementationClass {
    if (![implementationClass conformsToProtocol:instanceVaiableProtocolType]) [CDIException raise:@"Context and Dependency Injection" format:@"Protocol binding exception - %@ does not conform to %@.", implementationClass, NSStringFromProtocol(instanceVaiableProtocolType)];
    [self.implementationBindings setObject:implementationClass forKey:NSStringFromProtocol(instanceVaiableProtocolType)];
}

/**
 * For component auto-wiring the suitable implementation is search within all available classes.
 * The type of the implentation is one or more protocols, a class or an id.
 *
 * type = <NSCopying>
 * type = <NSCopying><NSCoding><NSObject>
 * type = NSDate
 * type = @
 */
- (Class)getClassForType:(NSString *)type {

    Class returnClass;

    if ([type hasPrefix:@"<"]) {
        // Protocol handling is a bit more complicated, so it si separated in another method
        returnClass= [self getClassForTypeProtocol:type];
    } else {
        // Found a simple class, first check for manual binding before auto resolving
        returnClass = [self.implementationBindings objectForKey:type];
        if (returnClass == nil) returnClass = NSClassFromString(type);
        if (returnClass == nil) [CDIException raise:@"Context and Dependency Injection" format:@"Unknown type %@", type];
    }
    return returnClass;
}

- (Class)getClassForTypeProtocol:(NSString *)protocolType {
    Class returnClass = nil;// Find implementation for all protocols
    NSArray *allProtocols = [protocolType componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];

    // First lookup for bindings
    // --------------------------------------------------
    // TODO Fix this code part to support multiple protocols (and clean code) - not just one
    int count = 0;
    for (NSString *protocol in allProtocols) {
        if ([protocol length] > 0) {
            count++;
            returnClass = [self.implementationBindings objectForKey:protocol];
        }
    }
    if(count==1 && returnClass) return returnClass;
    // --------------------------------------------------
    
    // Find all classes which implement exactly all the given protocols (auto-wiring)
    NSMutableArray *allPossibleClasses = [[NSMutableArray alloc] init];
    NSMutableArray *allUnpossibleClasses = [[NSMutableArray alloc] init];
    bool firstCall = YES;
    for (NSString *protocol in allProtocols) {
            if ([protocol length] > 0) {
                NSArray *classesImplementingProtocol = [protocolCache objectForKey:protocol];
                if (firstCall) {
                    [allPossibleClasses addObjectsFromArray:classesImplementingProtocol];
                    firstCall = NO;
                } else {
                    for (NSString *protocolToBeChecked in allPossibleClasses) {
                        if (![classesImplementingProtocol containsObject:protocolToBeChecked]) {
                            [allUnpossibleClasses addObject:protocolToBeChecked];
                        }
                    }
                }
            }
        }
    [allPossibleClasses removeObjectsInArray:allUnpossibleClasses];

    // Check whether multiple, one or none implementaions are suitable
    switch ([allPossibleClasses count]) {
            case 0:
                [CDIException raise:@"Context and Dependency Injection" format:@"Auto-wiring faild because the implementation could not be found for protocol %@", protocolType];
                break;
            case 1:
                returnClass = NSClassFromString([allPossibleClasses firstObject]);
                break;
            default:
                [CDIException raise:@"Context and Dependency Injection" format:@"Auto-wiring faild because of ambiguous implementations for protocol %@. Found multiple possible classes %@", protocolType, allPossibleClasses];
                break;
        }
    return returnClass;
}

- (NSDictionary *)ivarsFromClass:(Class)class {
    NSMutableDictionary *ivarsDict = [NSMutableDictionary new];
    unsigned int count;
    Ivar *ivars = class_copyIvarList(class, &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        [ivarsDict setObject:[NSString stringWithFormat:@"%s", typeEncoding] forKey:[NSString stringWithFormat:@"%s", name]];
    }
    free(ivars);
    return ivarsDict;
}

#pragma mark Singleton implementation

/**
 * Get the instance of the CDI singleton implementation.
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

/**
 * Initializer method of the CDI singleton.
 */
- (instancetype)initUniqueInstance {

    if (self = [super init]) {

    // Create the instance variables
    _implementationBindings = [[NSMutableDictionary alloc] init];
    protocolCache = [[NSMutableDictionary alloc] init];

    // Get all classes which are available in application scope
    int numberOfClasses;
    Class *classes = NULL;

    numberOfClasses = objc_getClassList(NULL, 0);

    if (numberOfClasses > 0) {
        classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * numberOfClasses);
        // Obtain all classes and store them in the classes as an array
        numberOfClasses = objc_getClassList(classes, numberOfClasses);

        for (int i = 0; i < numberOfClasses; i++) {
            // Identify the protocols of the class and store it inside protocol cache
            unsigned int protocolIndex = 0;
            Protocol *const *protocols = class_copyProtocolList(classes[i], &protocolIndex);
            if (protocols) {
                while (protocolIndex--) {
                    NSString *protocolName = [NSString stringWithUTF8String:protocol_getName(protocols[protocolIndex])];
                    NSMutableArray *classesContainingProtocol = [protocolCache objectForKey:protocolName];
                    // If there is no protocol array list, create a new one
                    if (!classesContainingProtocol) {
                        classesContainingProtocol = [[NSMutableArray alloc] init];
                        [protocolCache setValue:classesContainingProtocol forKey:protocolName];
                    }
                    // Add the class name to the protocol array list
                    [classesContainingProtocol addObject:[NSString stringWithUTF8String:class_getName(classes[i])]];
                }
                free((void *) protocols);
            }
        }
        free(classes);
    }
    }
    return self;
}

#pragma mark Objective-C Integration

/**
 * The doInject method is called before the init on any other NSObject creation. It will replace the
 * @inject annotation with an instance.
 */
#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"
- (id)initWithInject {
    
    id returnSelf =nil;
    
    NSMutableArray *interceptors = nil;
    
    // Avoid unlimited loop - injection will not be available in the CDI implementation itself
    if ([self isKindOfClass:[CDI class]]) {
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
                    [[CDI sharedInstance] createInstance:instanceVariableName inObject:self];
                } else {
                    // Extract the type and instance variable name
                    NSUInteger prefixLocation = [instanceVariableName rangeOfString:__INJECT_TYPE_PREFIX].location;
                    NSString *type = [instanceVariableName substringToIndex:prefixLocation];
                    instanceVariableName = [instanceVariableName substringFromIndex:[__INJECT_TYPE_PREFIX length] + prefixLocation];
                    // A class was defined as the type for the variable instantiation.
                    [[CDI sharedInstance] createInstance:instanceVariableName inObject:self ofType:type];
                }
            }
            
            // Check for interception injection
            // -------------------------------------
            if ([methodName hasPrefix:__INJECT_INTERCEPTOR]) {
                
                if(!interceptors) interceptors = [[NSMutableArray alloc] init];
                    // Get the interceptor class name which is encoded in the method name
                NSString *interceptorClassName = [methodName substringFromIndex:[__INJECT_INTERCEPTOR length]];
                
                    id interceptorClass = [[CDI sharedInstance] getClassForType:interceptorClassName];
                    // Create instance
                    id interceptorInstance = [[interceptorClass alloc] init];
                
                    // [interceptors insertObject:interceptorInstance atIndex:[interceptors count]];
                [interceptors insertObject:interceptorInstance atIndex:0];
                
                    // [[CDI sharedInstance] injectInterceptor:interceptorClassName inInstance:self];
            }
        }
        free((void *) methods);
    }
    // Now call the init (remember init was renamed to doInject)
    if(!returnSelf) returnSelf = [self initWithInject];
    
    // Process the interceptor injections
    if(interceptors) {
        returnSelf = [[CDIInterceptorProxy alloc] initWithTarget:returnSelf];
        [returnSelf setInterceptors:interceptors];
    }
    
    return returnSelf;
}

/**
 * Inject the interceptor into the instance.
 */
-(void)injectInterceptor:(NSString*)interceptorName inInstance:(id)instance {
    
    id interceptorClass = [self getClassForType:interceptorName];
    // Create instance
    id interceptorInstance = [[interceptorClass alloc] init];
    
    unsigned int methodIndex = 0;
    
    Method *methods = class_copyMethodList([instance class], &methodIndex);
    
    if (methods) {
        while (methodIndex--) {
            
            NSString *methodName = [NSString stringWithUTF8String:sel_getName(method_getName((methods[methodIndex])))];
            
            if ([methodName hasPrefix:__INJECT_INTERCEPTOR] || [methodName hasPrefix:__INJECT_METHOD]) continue;
            
            Method originalMethod = methods[methodIndex];
            SEL interceptorSelector = sel_registerName([[NSString stringWithFormat:@"%@__%@__%@",__INJECT_METHOD, interceptorName, methodName] UTF8String]);
            
            // The new implementation which will be used to replace the original method
            IMP newImplementationForMethod = imp_implementationWithBlock(^(id self, SEL releaseSelector, ...) {
                
                    // NSLog(@">>> %@",releaseSelector);
                
//                CDIInvocationContext *invocationContext = [[CDIInvocationContext alloc] initWithTarget:instance methodName:methodName implementationSelector:interceptorSelector];
            
                
                    // method_setImplementation(class_getClassMethod([interceptorInstance class], @selector(execute)),newIMP);
                
                    // id returnValue = [interceptorInstance invoke:invocationContext];
                
                return nil;
            });
            
            // Inject the interception method to the class and set the implementation of the
            // original method.
            if (class_addMethod([instance class], interceptorSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))) {
                // Replace the implementation of the original method with new implementation
                method_setImplementation(originalMethod,newImplementationForMethod);
            }
        }
        free((void *) methods);
    }
}

#pragma clang diagnostic pop

/**
 * Swap the implementation of the [NSObject init] with [CDI doInject].
 */
+(void) swapInitWithDoInjectMethod {
    
    Method initMethod = class_getInstanceMethod([NSObject class], @selector(init));
    Method doInjectMethod = class_getInstanceMethod([CDI class], @selector(initWithInject));

    if (class_addMethod([NSObject class], @selector(initWithInject), method_getImplementation(initMethod), method_getTypeEncoding(initMethod))) {
        method_exchangeImplementations(initMethod, doInjectMethod);
    }
}

+(instancetype)allocWithInitInjection {
    return [self allocWithInitInjection];
}

/**
 * Swap the implementation of the [NSObject init] with [CDI doInject].
 */
+(void) swapAllocWithAllocInjectMethod {
    Method allocMethod = class_getClassMethod([NSObject class], @selector(alloc));
    Method allocWithInitInjectionMethod = class_getClassMethod([CDI class], @selector(allocWithInitInjection));
    
    if (class_addMethod([NSObject class], @selector(allocWithInitInjection), method_getImplementation(allocMethod), method_getTypeEncoding(allocMethod))) {
        method_exchangeImplementations(allocMethod, allocWithInitInjectionMethod);
    }
}

/**
 * Initialize will replace the init implementation of NSObject.
 */
+ (void) initialize {
    if (self == [CDI class]) {
        [self swapAllocWithAllocInjectMethod];
            [self swapInitWithDoInjectMethod];
    }
}


@end
