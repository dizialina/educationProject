//
//  DBClient.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "ObjClient.h"
#import "Constants.h"
#import "sqlite3.h"
#import "RateItemFromGov.h"
#import "RateItemFromYahoo.h"
#import "FMDB/FMDB.h"

@implementation ObjClient {
    sqlite3 *database;
}

- (int)testMethod:(int)testInt {
    testInt +=1;
    return testInt;
}

#pragma mark - Methods working with file data base

- (NSString *)copyDBFileToPathIfNotExistsAndReturnAdress {
    
    NSArray *pathsToFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathDocumentsFolder = [pathsToFolders lastObject];

    //NSLog(@"%@", pathDocumentsFolder);

    NSString *stringDBPath = [NSString stringWithFormat:@"%@/%@", pathDocumentsFolder, DBName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL succes = [manager fileExistsAtPath:stringDBPath];
    if (!succes) {
        NSString *pathDBInBundle = [NSString stringWithFormat:@"%@/%@", [NSBundle mainBundle].resourcePath, DBName];

     	BOOL success = [manager copyItemAtPath:pathDBInBundle toPath:stringDBPath error:nil];
        if (!success) {
            NSLog(@"Error copy file to Documents");
        }
    } else {
        //NSLog(@"File exist in Documents folder");
    }
    
    return stringDBPath;
}

#pragma mark - Transaction method for writing data to database

- (BOOL)openDB {
    BOOL returnBool = NO;
    NSString *stringDBPath = [self copyDBFileToPathIfNotExistsAndReturnAdress];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK) {
        returnBool = YES; }
    return returnBool;
}

- (void)closeDB {
    sqlite3_close(database);
}


- (BOOL) writeWithTransactionRequestToDatabase:(NSArray*)arrayRequests {
    
    if ([arrayRequests count] != 0) {
    FMDatabase *db = [FMDatabase databaseWithPath:[self copyDBFileToPathIfNotExistsAndReturnAdress]];
        if (![db open]) {
            [db close];
        }
        NSLog(@"Count of request array:%lu", (unsigned long)arrayRequests.count);
        [db open];
        [db beginTransaction];
        for (NSString *request in arrayRequests) {
            //[db executeQuery:request];
            [db executeUpdate:request];
           
        }
        [db commit];
        [db close];
        return YES;
    }
    return NO;
}

#pragma mark - Select methods with FMDB

- (NSArray *)returnCurrencyRateObjectArrayFromGovDBWithFMDB:(NSString *)request {
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self copyDBFileToPathIfNotExistsAndReturnAdress]];
    
    if (![db open]) {
        [db close];
    }
    
    [db open];

    FMResultSet *s = [db executeQuery:request];
    
    while ([s next]) {
        RateItemFromGov *bankItem = [RateItemFromGov new];
        bankItem.shortCurName = [s stringForColumnIndex:0];
        bankItem.rate = [s doubleForColumnIndex:1];
        [currencyRateArray addObject:bankItem];
    }
    
    [db close];
    
    NSArray *returnArray = [NSArray arrayWithArray:currencyRateArray];
    return returnArray;
}

- (NSArray *)returnCurrencyRateObjectArrayFromYahooBDWithFMDB:(NSString *)request {
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self copyDBFileToPathIfNotExistsAndReturnAdress]];
    
    if (![db open]) {
        [db close];
    }
    
    [db open];
    
    FMResultSet *s = [db executeQuery:request];
    
    while ([s next]) {
        RateItemFromYahoo *bankItem = [RateItemFromYahoo new];
        bankItem.pairCurName = [s stringForColumnIndex:0];
        bankItem.rate = [s doubleForColumnIndex:1];
        bankItem.ask = [s doubleForColumnIndex:2];
        bankItem.bid = [s doubleForColumnIndex:3];
        [currencyRateArray addObject:bankItem];
    }
    
    [db close];
    
    NSArray *returnArray = [NSArray arrayWithArray:currencyRateArray];
    return returnArray;
    
}

@end


