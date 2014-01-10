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
#import "CDIInterceptor.h"
#import "CDIInjector.h"

/**
* CDI is the main class of the context and dependency injection implementation. CDI has to be initialized properly and
* it is recommended to execute it at the beginning of the application code.
*
    @textblock
    + (void)initialize {
       [super initialize];
       // Enable context and dependency injection
       [CDI initialize];
    }
    @/textblock
*/
@interface CDI : NSObject

/**
* Perform initialization of an instance and inject all interceptors except if the reference is a filtered class type.
*
* @param reference The instance which is used to add the interceptors.
* @return A reference with added interceptors.
*/
+ (id)performInstanceInitializationWithInterceptors:(id)reference;

/**
* Perform initialization of an instance and inject all interceptors.
*
* @param reference The instance which is used to add the interceptors.
* @param ignoreInterceptorFilter YES to ignore the filter and force the injections of the interceptors.
* @return A reference with injected interceptors.
*/
+ (id)performInstanceInitializationWithInterceptors:(id)reference ignoreFilter:(BOOL)ignoreInterceptorFilter;

/**
* Perform initialization of an instance and inject all interceptors except if the reference is a filtered class type.
*
* @param reference The instance which is used to add the interceptors.
* @return A reference with injected instance variables.
*/
+ (id)performInstanceInitializationWithInjectors:(id)reference;

/**
* Add a class to the interceptor filter, which will prevent adding interceptors to instances of the given class types.
*
* @param class The class which will be added to the filter.
*/
+ (void)addInterceptorClassFilter:(Class)class;

/**
* Initialize will replace the init implementation of classes like NSObject.
*/
+ (void)initialize;

@end