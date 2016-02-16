//
//  XoxolTests.m
//  XoxolTests
//
//  Created by Roman.Safin on 2/13/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjClient.h"

@interface XoxolTests : XCTestCase

@end

@implementation XoxolTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testTheMethodInViewController {
    
    ObjClient *screen = [ObjClient new];
    int random = arc4random_uniform(30);
    int result = [screen testMethod:random];
    int rightResult = random + 1;
    XCTAssertEqual(result, rightResult,@"Right result: (%i) equal to method number (%i)",rightResult,random);
    
}

- (void)testTheMethodReturnObjectArray {
    
    ObjClient *objClient = [ObjClient new];
    NSString *request = @"SELECT * FROM yahooCurrencyRate1";
    NSArray *result = [objClient returnCurrencyRateObjectArrayFromYahooBDWithFMDB:request];
    //NSLog(@"test array %@", result);
    XCTAssertNotNil(result);
    
}

@end
