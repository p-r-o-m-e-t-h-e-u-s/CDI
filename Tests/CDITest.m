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

#import <XCTest/XCTest.h>
#import "CDIInjector.h"

@protocol TestProtocol <NSObject>
@end

@interface TestProtocolClass : NSObject <TestProtocol>
@end

@implementation TestProtocolClass
@end

@protocol TestProtocolMultiple1 <NSObject>
@end

@protocol TestProtocolMultiple2 <NSObject>
@end

@protocol TestProtocolMultiple3 <NSObject>
@end

@interface TestProtocolMultiple : NSObject <TestProtocolMultiple1, TestProtocolMultiple2, TestProtocolMultiple3>
@end

@implementation TestProtocolMultiple
@end

@protocol TestMultipleImplementationsProtocol <NSObject>
@end

@interface TestMultipleImplementations1 : NSObject <TestMultipleImplementationsProtocol>
@end

@implementation TestMultipleImplementations1
@end

@interface TestMultipleImplementations2 : NSObject <TestMultipleImplementationsProtocol>
@end

@implementation TestMultipleImplementations2
@end

@interface TestSingleton : NSObject
@end

@singleton(TestSingleton);
@implementation TestSingleton
@end

@interface TestSingletonInjection : NSObject
@property(nonatomic) TestSingleton *testSingletonInjection;
@property(nonatomic) NSDate *testNoneSingletonInjection;
@end

@implementation TestSingletonInjection
@inject(testSingletonInjection)
@inject(testNoneSingletonInjection)
@end

@protocol TestBindingImplementationsProtocol <NSObject>
@end

@interface TestBindingImplementations1 : NSObject <TestBindingImplementationsProtocol>
@end

@implementation TestBindingImplementations1
@end

@interface TestBindingImplementations2 : NSObject <TestBindingImplementationsProtocol>
@end

@implementation TestBindingImplementations2
@end

@interface TestBindingClass : NSObject
@end

@implementation TestBindingClass
@end

@interface TestBindingSubclass : TestBindingClass
@end

@implementation TestBindingSubclass
@end


@interface CDITest : XCTestCase {
    // Context and dependency injection implementation
    CDIInjector *cdi;

    NSDate *testInstance;

    id <TestProtocol> testProtocol;

    id <TestProtocolMultiple1, TestProtocolMultiple2, TestProtocolMultiple3> testProtocolMultiple;

    id testUnknownImplementationVariable;

    id <TestMultipleImplementationsProtocol> testMultipleImplementationsProtocol;

    id testInstanceOfType;

    id <TestBindingImplementationsProtocol> testBindingImplementationsProtocol;

    TestBindingClass *testBindingClass;
}

@end

@implementation CDITest

- (void)setUp {
    [super setUp];

    // Put setup code here; it will be run once, before the first test case.
    cdi = [CDIInjector sharedInstance];

    testInstance = nil;
    testProtocol = nil;
    testProtocolMultiple = nil;
    testUnknownImplementationVariable = nil;
    testMultipleImplementationsProtocol = nil;
    testInstanceOfType = nil;
    testBindingClass = nil;
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSharedInstance {
    if (cdi != [CDIInjector sharedInstance]) XCTFail(@"Singleton implementation seems wrong \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithClass {
    [cdi createInstance:@"testInstance" inObject:self];
    XCTAssertNotNil(testInstance, @"testInstance instance variable was not created \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithProtcol {
    [cdi createInstance:@"testProtocol" inObject:self];
    XCTAssertNotNil(testProtocol, @"testProtocol instance variable was not created \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithMultipleProtcol {
    [cdi createInstance:@"testProtocolMultiple" inObject:self];
    XCTAssertNotNil(testProtocolMultiple, @"testProtocolMultiple instance variable was not created \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithUnknownImplementation {
    XCTAssertThrowsSpecific([cdi createInstance:@"testUnknownImplementationVariable" inObject:self], CDIException, @"Did not throw an cdi exception \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithMultipleImplementations {
    XCTAssertThrowsSpecific([cdi createInstance:@"testMultipleImplementationsProtocol" inObject:self], CDIException, @"Did not throw an cdi exception \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceOfType {
    [cdi createInstance:@"testInstanceOfType" inObject:self ofType:@"NSDate"];
    XCTAssertTrue([testInstanceOfType isKindOfClass:[NSDate class]], @"testInstanceOfType instance variable was not created properly \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceOfUnknownType {
    XCTAssertThrowsSpecific([cdi createInstance:@"testInstanceOfType" inObject:self ofType:@"xxx"], CDIException, @"Did not throw an cdi exception \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithSingletonInjection {
    TestSingletonInjection *testObject1 = [[TestSingletonInjection alloc] init];
    TestSingletonInjection *testObject2 = [[TestSingletonInjection alloc] init];
    XCTAssertTrue(testObject1.testSingletonInjection == testObject2.testSingletonInjection, @"Singleton implementation is not unique \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertNotNil(testObject1.testSingletonInjection, @"Singleton implementation is not unique \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testCreateInstanceWithNoneSingletonInjection {
    TestSingletonInjection *testObject1 = [[TestSingletonInjection alloc] init];
    TestSingletonInjection *testObject2 = [[TestSingletonInjection alloc] init];
    NSLog(@"%@ == %@", testObject1.testNoneSingletonInjection, testObject2.testNoneSingletonInjection);
    XCTAssertFalse(testObject1.testNoneSingletonInjection == testObject2.testNoneSingletonInjection, @"None singleton implementation is unique \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testManualBindingSingleProtocol {
    Protocol *protocol = @protocol(TestBindingImplementationsProtocol);
    [cdi bindProtocol:protocol with:[TestBindingImplementations1 class]];
    [cdi createInstance:@"testBindingImplementationsProtocol" inObject:self];
    XCTAssertTrue([testBindingImplementationsProtocol isKindOfClass:[TestBindingImplementations1 class]], @"testManualBindingProtocol failed to create the specified instance \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testManualBindingClass {
    [cdi bindClass:[TestBindingClass class] with:[TestBindingSubclass class]];
    [cdi createInstance:@"testBindingClass" inObject:self];
    XCTAssertTrue([testBindingClass isKindOfClass:[TestBindingSubclass class]], @"testManualBindingClass failed to create the specified instance \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testManualBindingProtocolIsNotConform {
    Protocol *protocol = @protocol(TestBindingImplementationsProtocol);
    XCTAssertThrowsSpecific([cdi bindProtocol:protocol with:[NSDate class]], CDIException, @"Did not throw an cdi exception \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testManualBindingClassIsNotSubclass {
    XCTAssertThrowsSpecific([cdi bindClass:[NSString class] with:[NSDate class]], CDIException, @"Did not throw an cdi exception \"%s\"", __PRETTY_FUNCTION__);
}

@end
