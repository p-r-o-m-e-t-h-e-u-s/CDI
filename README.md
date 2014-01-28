CDI
===

### Context and Dependency Injection for Objective-C

[![Version](https://cocoapod-badges.herokuapp.com/v/CDI/badge.png)](http://cocoadocs.org/docsets/CDI)
[![Platform](https://cocoapod-badges.herokuapp.com/p/CDI/badge.png)](http://cocoadocs.org/docsets/CDI)

Simple, easy and very powerful way to use context and dependency injection and interception for objective c development. CDI is designed to solve some common software development patterns like [Dependency Injection](http://en.wikipedia.org/wiki/Dependency_injection) / [Inversion of Control](http://en.wikipedia.org/wiki/Inversion_of_control), [Singleton](http://en.wikipedia.org/wiki/Singleton_pattern) and [Interception](http://en.wikipedia.org/wiki/Interceptor_pattern) (an minimalistic [AOP](http://en.wikipedia.org/wiki/Aspect-oriented_programming) approach). It follows convention over configuration and performs just on runtime.

The main features are:

* Injection by annotation
* Component auto-wiring
* Manual object binding
* Singleton by annotation
* Interception by annotation


Using CDI will reduce the boilerplate code in many classes, increase readability and allow better testing. The interception functionality will also provide the ability to separate the implementation code by aspects like security, logging and other facets.

CDI does not depend on another framework, which means you can use any unit testing, mocking or other framework *(see Limitation chapter)*.

Here are some samples:

### Sample 1: Simple injection using auto-wiring

```objc
@interface InjectExample: NSObject
// Let's say you have one class which implements the MyServiceProtocol
...
@property(nonatomic, readwrite) id<MyServiceProtocol> *myService;
...
@end
    
@implementation InjectExample
...
// Using @inject instead of @synthesize will lookup the 
// implementation class at runtime and create the instance automatically
@inject(myService);
...
@end
```

**Discussion:**

__@inject__ will find any suitable implementations wich conforms to __MyServiceProtocol__, create an instance automatically and assign it to the instance variable or property like __myService__. Unless there is just one suitable implementation, the instance can be created without further configuration. This is called auto-wiring by convention over configuration.
If multiple implementations are available, CDI will throw an __CDIException__ because it cannot determine the right implementation. In this case manual wiring or binding is required.

**Full Sample Code:**

* [Service Protocol](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1Service.h)
* [Specific Service Interface](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1ServiceImplementation.h)
* [Specific Service Implementation](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample1ServiceImplementation.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample1Controller.m)


### Sample 2: Simple injection using manual wiring

```objc
@interface InjectExample: NSObject
...
// Let's say you have multiple classes which implements the MyServiceProtocol
@property(nonatomic, readwrite) id<MyServiceProtocol> *myService;
...
@end
    
@implementation InjectExample
...
// Using @inject with an implementation class which will be
// used to create the myService instance 
@inject(myService, MyServiceImplementation);
...
@end
```
    
**Discussion:**

__@inject__ will create an instance of __MyServiceImplementation__ and assign it to the instance variable or property like __myService__. This is useful if you exactly know the implementation class of the instance variable type. Also if multiple possible implementations are available at runtime, this has to be used to define the relevant implementation class.

**Full Sample Code:**

* [Service Protocol](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample2Service.h)
* [Specific Service Interface](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample2ServiceImplementation.h)
* [Specific Service Implementation](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample2ServiceImplementation.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample2Controller.m)

#### Sample 3: Simple injection with classes
```objc
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
```

**Discussion:**

__@inject__ will create an instance of __NSDate__ and assign it to the instance variable or property like __now__. In this case the implementation is identical to the instance variable type, which is used to create the instance. CDI will use the default instantiation method `-(id) init` to complete the object creation.

The example `@inject(now);` is a reduced code of `synthesize now;` and `_now = [[NSDate alloc] init];` 

**Full Sample Code:**

* [Sample Controller Interface ](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample3Controller.h)
* * [Sample Controller Implementation ](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample3Controller.m)


#### Sample 4: Simple singleton implementation
   
```objc
@interface MySample4ServiceImplementation : NSObject <MySample4Service>
...
@end

// Define MySample4ServiceImplementation as a singleton
@singleton(MySample4ServiceImplementation);

@implementation MySample4ServiceImplementation
...
@end
```

**Discussion:**

__@singleton__ will augment the class __MySample4ServiceImplementation__ so that injecting an instance will always apply the unique instance. This fourth sample implementation is identical with the first sample, except that `@inject(myService);` will create just once an instance for the lifetime of the application.  

**Full Sample Code:**
* [Service Protocol](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample4Service.h)
* [Specific Service Interface](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample4ServiceImplementation.h)
* [Specific Service Implementation](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/MySample4ServiceImplementation.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample4Controller.m)

#### Sample 5: Interceptor implementation
    
```objc
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
```

**Discussion:**

Interceptors are very useful to separated code with different aspects. For security reasons a [Facade](http://en.wikipedia.org/wiki/Facade_pattern) or [Input Validation](http://en.wikipedia.org/wiki/Input_validation) can be easily integrated using interceptors. Or Logging, tracing and profiling can easily be activated at runtime. All these and other aspects can smartly be separated from the application logic.

**Full Sample Code:**

* [Method Logger Interceptor](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5MethodLoggerInterceptor.m)
* [Time Interceptor](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5TimeInterceptor.m)
* [Sample Controller](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/Sample5Controller.m)


#### Sample 6: Simple manual binding
    
```objc
// Override the auto-wiring by binding new implementation classes to use mocking objects.
// Your test just needs to use the bindProtocol or bindClass method in the setup of your
// Unit testing framework.
[[CDI sharedInstance] bindProtocol:@protocol(ExampleProtocol) with:[MyMock class]];
```

**Discussion:**

*(To be defined.)* 

**Full Sample Code:**

*(To be defined.)* 

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

The injected instance variables are created before the class instance initialization methods `(init...)` and therefore can be used within. The interceptors are instantiated after the class instance initialization methods `(init...)` and are therefore
perform after the instance creation.

## Limitation

***CDI is under development and there still may be some unknown issues.***

**Known issues are:**

__Open:__

* Compatibility problems with OCMock

__Fixed:__

* Subclasses of UIViewController currently do not support interception. _[FIXED 1.0.0-beta3]_

Please report issues [here](https://github.com/real-prometheus/CDI/issues).

## Installation

CDI is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "CDI"
    
CDI has to be enabled before it can be used for development. Open the `AppDelegate.m` *(or any similar class which is executed at the beginning of the application)* and add the following `initialize` method to the implementation:

```objc
#import "AppDelegate.h"
#import <CDI.h>

@implementation AppDelegate
	
...
	
+(void)initialize {
    [super initialize];
    // Enable context and dependency injection
    [CDI initialize];
}
	
@end
```

**Full Sample Code:**

* [AppDelegate Example](https://github.com/real-prometheus/CDI/blob/master/Project/Sample/Sample/AppDelegate.m)

## License

CDI is available under the MIT license. See the LICENSE file for more information.
