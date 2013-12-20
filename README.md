CDI
===

Context and Dependency Injection for Objective C

Simple, easy and very powerful way to use context and dependency injection for objective c development. The main features are:
* Injection by annotation
* Component auto-wiring
* Easy singleton support
* Manual object binding

Using CDI will reduce the boilerplate code in many classes, increase readability and allow better testing using the mocking technique. CDI is independend of any other framework, which means you can use any unit testing framework. Code samples are provided for XCTest.

Here are some samples:

#### Simple injection using auto-wiring ####

    @interface InjectExample: NSObject
    // Let's say you have one class which implements the MyServiceProtocol
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    @end
    
    @implementation InjectExample
    // Using @inject instead of @synthesize will lookup the 
    // implementation class at runtime and create the instance automatically
    @inject(myService);
    @end

#### Simple injection using manual wiring ####

    @interface InjectExample: NSObject
    // Let's say you have multiple classes which implements the MyServiceProtocol
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    @end
    
    @implementation InjectExample
    // Using @inject with a implementation class which will be
    // used to create the myService instance 
    @inject(myService, MyServiceImplementation);
    @end
    
#### Simple injection with classes ####
    @interface InjectExample: NSObject
    // Let's say you have a property with a class type
    @property(nonatomic, readwrite) NSDate *now;
    @end
    
    @implementation InjectExample
    // Using @inject will create a new instance automatically
    // containing the current date and time 
    @inject(now);
    @end
    
#### Simple singleton implementation ####
    @interface SingletonExample: NSObject
    @end
    
    // This annotation will produce a singleton implementation
    // for SingletonExample. Inject it into other classes to
    // access the unique instance.
    @singleton(SingletonExample);
    
    @implementation SingletonExample
    @end
    
#### Simple manual binding ####
    
    // Override the auto-wiring by binding new implementation classes to use mocking objects.
    // Your test just needs to use the bindProtocol or bindClass method in the setup of your
    // Unit testing framework.
    [[CDI sharedInstance] bindProtocol:@protocol(ExampleProtocol) with:[MyMock class]];

More to follow soon...
