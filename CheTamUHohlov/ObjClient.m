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

#pragma mark - Main Methods

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

- (NSArray *)returnCurrencyRateObjectArrayFromGovDB:(NSString *)request {
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    NSString *stringDBPath = [self copyDBFileToPathIfNotExistsAndReturnAdress];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK) {
        const char *receivedRequest = [request UTF8String];
        sqlite3_stmt *readStatement = nil;
        if(sqlite3_prepare_v2(database, receivedRequest, -1, &readStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while reading statement. '%s'", sqlite3_errmsg(database));
        }
        while (sqlite3_step(readStatement) == SQLITE_ROW) {
            RateItemFromGov *bankItem = [RateItemFromGov new];
            //NSLog(@"%s",sqlite3_column_text(readStatement, 0));
            char * shortName = (char *)sqlite3_column_text(readStatement, 0);
            bankItem.shortCurName = [NSString stringWithUTF8String:shortName];
            bankItem.rate = sqlite3_column_double(readStatement, 1);
            char * fullName = (char *)sqlite3_column_text(readStatement, 2);
            bankItem.fullName = [NSString stringWithUTF8String:fullName];
            [currencyRateArray addObject:bankItem];
        }
        sqlite3_reset(readStatement);
    }
    sqlite3_close(database);
    
    NSArray *returnArray = [NSArray arrayWithArray:currencyRateArray];
    return returnArray;
}

#pragma mark - Methods working with Yahoo server

- (NSArray *)returnCurrencyRateObjectArrayFromYahooBD:(NSString *)request { 
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    NSString *stringDBPath = [self copyDBFileToPathIfNotExistsAndReturnAdress];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK) {
        const char *receivedRequest = [request UTF8String];
        sqlite3_stmt *readStatement = nil;
        if(sqlite3_prepare_v2(database, receivedRequest, -1, &readStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while reading statement. '%s'", sqlite3_errmsg(database));
        }
        while (sqlite3_step(readStatement) == SQLITE_ROW) {
            RateItemFromYahoo *bankItem = [RateItemFromYahoo new];
            //NSLog(@"%s",sqlite3_column_text(readStatement, 0));
            char * name = (char *)sqlite3_column_text(readStatement, 0);
            bankItem.pairCurName = [NSString stringWithUTF8String:name];
            bankItem.rate = sqlite3_column_double(readStatement, 1);
            bankItem.ask = sqlite3_column_double(readStatement, 2);
            bankItem.bid = sqlite3_column_double(readStatement, 3);
            [currencyRateArray addObject:bankItem];
        }
        sqlite3_reset(readStatement);
    }
    sqlite3_close(database);
    
    NSArray *returnArray = [NSArray arrayWithArray:currencyRateArray];
    return returnArray;
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
        [db open];
        [db beginTransaction];
        for (NSString *request in arrayRequests) {
            //[db executeQuery:request];
            [db executeUpdate:request];
            //NSLog(@"%@", request);
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


