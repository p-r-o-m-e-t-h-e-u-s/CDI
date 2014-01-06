CDI
===

Context and Dependency Injection for Objective C

[![Version](https://cocoapod-badges.herokuapp.com/v/CDI/badge.png)](http://cocoadocs.org/docsets/CDI)
[![Platform](https://cocoapod-badges.herokuapp.com/p/CDI/badge.png)](http://cocoadocs.org/docsets/CDI)

Simple, easy and very powerful way to use context and dependency injection and interception for objective c development. CDI is designed to solve some common software development patterns like [Dependency Injection](http://en.wikipedia.org/wiki/Dependency_injection) / [Inversion of Control](http://en.wikipedia.org/wiki/Inversion_of_control), [Singleton](http://en.wikipedia.org/wiki/Singleton_pattern) and [Interception](http://en.wikipedia.org/wiki/Interceptor_pattern) (an minimalistic [AOP](http://en.wikipedia.org/wiki/Aspect-oriented_programming) support).

The main features are:

* Injection by annotation
* Component auto-wiring
* Manual object binding
* Easy singleton support
* Interception support


Using CDI will reduce the boilerplate code in many classes, increase readability and allow better testing. The intreception functionality will also provide the ability to separate the implementation code by aspects like security, logging and other facets.

CDI does not depend on another framework, which means you can use any unit testing, mocking or other framework *(see Limitation chapter)*. Code samples are provided for XCTest.

Here are some samples:

#### Simple injection using auto-wiring

    @interface InjectExample: NSObject
    // Let's say you have one class which implements the MyServiceProtocol
    ...
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    ...
    @end
    
    @implementation InjectExample
    ...
    // Using @inject instead of @synthesize will lookup the 
    // implementation class at runtime and create the instance automatically
    @inject(myService);
    ...
    @end

**Full Sample Code:**

* [Service Protocol](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1Service.h)
* [Specific Service Interface](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1ServiceImplemetation.h)
* [Specific Service Implementation](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1ServiceImplemetation.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample1Controller.m)


#### Simple injection using manual wiring

    @interface InjectExample: NSObject
    ...
    // Let's say you have multiple classes which implements the MyServiceProtocol
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    ...
    @end
    
    @implementation InjectExample
    ...
    // Using @inject with a implementation class which will be
    // used to create the myService instance 
    @inject(myService, MyServiceImplementation);
    ...
    @end
    
#### Simple injection with classes
    @interface InjectExample: NSObject
    ...
    // Let's say you have a property with a class type
    @property(nonatomic, readwrite) NSDate *now;
    ...
    @end
    
    @implementation InjectExample
    ...
    // Using @inject will create a new instance automatically
    // containing the current date and time 
    @inject(now);
    ...
    @end
    
#### Simple singleton implementation
    @interface SingletonExample: NSObject
    ...
    @end
    
    // This annotation will produce a singleton implementation
    // for SingletonExample. Inject it into other classes to
    // access the unique instance.
    @singleton(SingletonExample);
    
    @implementation SingletonExample
    ...
    @end
    
#### Simple manual binding
    
    // Override the auto-wiring by binding new implementation classes to use mocking objects.
    // Your test just needs to use the bindProtocol or bindClass method in the setup of your
    // Unit testing framework.
    [[CDI sharedInstance] bindProtocol:@protocol(ExampleProtocol) with:[MyMock class]];

#### Interceptor implementation
    // This is a very simple method execution logger.
    @interface MethodLoggerInterceptor : CDIInterceptor
	@end

	@implementation MethodLoggerInterceptor
	// The invoke method is called on each method call.
	-(void)invoke:(CDIInvocationContext *)context {
    	NSLog(@"--> Entering [%@:%@]", context.target, context.method);
    	[context execute];
    	NSLog(@"<-- Leaving  [%@:%@]", context.target, context.method);
	}
	@end
	
	@interface MyDemo : NSObject {
		...
		-(void)doDemo;
		...
	}
	
	@intercept(MyDemo,MethodLoggerInterceptor)
	
	@implementation MyDemo
	...
	// This method will be surrounded automatically with entering and leaving log messages.
	-(void)doDemo {
    	...
	}
	...
	@end
	
**Full Sample Code:**

* [Method Logger Interceptor](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5MethodLoggerInterceptor.m)
* [Time Interceptor](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5TimeInterceptor.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5Controller.m)

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

The injected elements are accessable after the initialization methods `(init...)`.

## Limitation

***CDI is under development and there still may be some unknown issues.***

**Known issues are:**

* Subclasses of UIViewController currently do not support interception.
* Compatibility problems with OCMock

Please report issues [here](https://github.com/real-prometheus/CDI/issues).

## Installation

CDI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "CDI"
    
CDI has to be enabled before it can be used for development. Open the `AppDelegate.m` *(or any similar class which is executed at the beginning of the application)* and add the following `initialize` method to the implementation:

	#import "AppDelegate.h"
	#import <CDI.h>

	@implementation AppDelegate
	
	...
	
	+(void)initialize
	{
    	[super initialize];
    	// Enable context and dependency injection
    	[CDI initialize];
	}
	
	@end

## License

CDI is available under the MIT license. See the LICENSE file for more information.
