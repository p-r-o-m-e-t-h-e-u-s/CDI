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


// This prefix is used to identify the injectable instance variable
#define __INJECT_INSTANCE_PREFIX @"__inject_instance__"
#define __INJECT_TYPE_PREFIX @"__inject_type__"

/**
 * The inject macro which is can used to create an instance and assign
 * it to the instance variable of a class.
 *
 * Use:
 * @inject(variable);
 *
 */
#define inject(instanceVariableName,...) synthesize instanceVariableName;\
-(void) __inject_instance__ ## __VA_ARGS__ ## __inject_type__ ## instanceVariableName {}

/**
 * The singleton macro generates the sharedInstance method automatically. It creates
 * a new category with the name CDISingleton for the implementation.
 *
 * Use:
 * @singleton(name)
 */
#define singleton(name) interface name (ContextAndDependencyInjection)\
+ (instancetype)sharedInstance;\
@end\
@implementation name (ContextAndDependencyInjection)\
+ (instancetype)sharedInstance\
{\
    static id sharedInstance = nil;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        sharedInstance = [[self alloc] init];\
    });\
    return sharedInstance;\
}\
@end\


/**
 * CDIException are thrown by the cdi implementation whenever a unrecoverable situation occurs.
 */
@interface CDIException : NSException
@end

/**
 * Context and dependency injection.
 */
@interface CDI : NSObject

/**
 * Create an object and assign it to the instance variable.
 */
- (void)createInstance:(NSString *)variableName inObject:(id)instance;

/**
 * Create an object of a specific type and assign it to the instance variable.
 */
- (void)createInstance:(NSString *)variableName inObject:(id)object ofType:(NSString *)type;

/**
 * Bind the instance variable class type with an implementation class to override the auto-wiring.
 * Using this will allow a manual wiring, which is suitable for replacing implementation
 * with mocking objects.
 */
- (void)bindClass:(Class)instanceVaiableType with:(Class)implementationClass;

/**
 * Bind the instance variable protocol type with an implementation class to override the auto-wiring.
 * Using this will allow a manual wiring, which is suitable for replacing implementation
 * with mocking objects.
 */
- (void)bindProtocol:(Protocol *)instanceVaiableProtocolType with:(Class)implementationClass;

/**
 * Get the instance of this CDI implementation.
 */
+ (instancetype)sharedInstance;

// clue for improper use (produces compile time error)
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));

- (instancetype)init __attribute__((unavailable("init not available, call sharedInstance instead")));

+ (instancetype)new __attribute__((unavailable("new not available, call sharedInstance instead")));


@end
