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


- (void)testTheMethodReturnPathToDatabase {
    
    ObjClient *objClient = [ObjClient new];
    NSString *path = [objClient copyDBFileToPathIfNotExistsAndReturnAdress];
    BOOL isDBExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    XCTAssertTrue(isDBExist);
    
}


- (void)testTheMethodWriteToDatabase {
    
    ObjClient *objClient = [ObjClient new];
    NSArray *arrayWithRequest = [NSArray arrayWithObject:@"INSERT OR REPLACE INTO yahooCurrencyRate VALUES (\'USD/RUB\', 75.4456, 75.4586, 75.4456)"];
    //NSArray *arrayWithWrongRequest = [NSArray arrayWithObject:@"aaaaaaaa"];
    BOOL writeSucces = [objClient writeWithTransactionRequestToDatabase:arrayWithRequest];
    XCTAssertTrue(writeSucces);
    
}


@end
