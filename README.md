CDI
===

Context and Dependency Injection for Objective C

Simple, easy and very powerful way to use context and dependency injection for objective c development. The main features are:
* Injection by annotation
* Component auto-wiring
* Easy singleton support
* Manual object binding

Using CDI will reduce the boilerplate code in many classes, increase readability and allow better testing using the mocking technique.

Here are some samples:

#### Simple injection using auto-wiring ####

    @interface InjectExample: NSObject
    // Let's say you have one class which implements the MyServiceProtocol
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    @end
    
    @implementation
    // Using @inject instead of @synthesize will lookup the implementation class at runtime and create the instance automatically
    @inject(myService);
    @end

#### Simple injection using manual wiring ####

    @interface InjectExample: NSObject
    // Let's say you have multiple classes which implements the MyServiceProtocol
    @property(nonatomic, readwrite) MyServiceProtocol *myService;
    @end
    
    @implementation
    // Using @inject with a implementation class which will be used to create the myService instance 
    @inject(myService, MyServiceImplementation);
    @end
    
#### Simple injection with classes ####
    @interface InjectExample: NSObject
    // Let's say you have a property with a class type
    @property(nonatomic, readwrite) NSDate *now;
    @end
    
    @implementation
    // Using @inject will create a new instance automatically containing the current date and time 
    @inject(now);
    @end

More to follow soon...
