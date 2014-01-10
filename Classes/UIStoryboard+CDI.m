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
#import "UIStoryboard+CDI.h"
#import <objc/runtime.h>
#import "CDI.h"

@implementation UIStoryboard (CDI)

- (id)__cdi_instantiateInitialViewController {

    id viewController = [self __cdi_instantiateInitialViewController];

    viewController = [CDI performInstanceInitializationWithInjectors:viewController];
    viewController = [CDI performInstanceInitializationWithInterceptors:viewController ignoreFilter:YES];


    return viewController;
}

- (id)__cdi_instantiateViewControllerWithIdentifier:(NSString *)identifier {

    id viewController = [self __cdi_instantiateViewControllerWithIdentifier:identifier];

    viewController = [CDI performInstanceInitializationWithInjectors:viewController];
    viewController = [CDI performInstanceInitializationWithInterceptors:viewController ignoreFilter:YES];


    return viewController;
}

/**
 * Swap the implementation of the [NSObject init] with [CDIInjector initWithContextAndDependencyInjection].
 */
+ (void)swapInit {

    Method instantiateInitialViewControllerMethod = class_getInstanceMethod([UIStoryboard class], @selector(instantiateInitialViewController));
    Method __cdi_instantiateInitialViewControllerMethod = class_getInstanceMethod([UIStoryboard class], @selector(__cdi_instantiateInitialViewController));
    method_exchangeImplementations(instantiateInitialViewControllerMethod,
            __cdi_instantiateInitialViewControllerMethod);


    Method instantiateViewControllerWithIdentifierMethod = class_getInstanceMethod([UIStoryboard class], @selector(instantiateViewControllerWithIdentifier:));
    Method __cdi_instantiateViewControllerWithIdentifierMethod = class_getInstanceMethod([UIStoryboard class],
            @selector(__cdi_instantiateViewControllerWithIdentifier:));
    method_exchangeImplementations(instantiateViewControllerWithIdentifierMethod, __cdi_instantiateViewControllerWithIdentifierMethod);

}

@end