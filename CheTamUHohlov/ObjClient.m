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

#pragma mark - Methods working with file database

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

- (BOOL) writeRequestToDatabase:(NSString*)request {
    
    BOOL success;
    FMDatabase *db = [FMDatabase databaseWithPath:[self copyDBFileToPathIfNotExistsAndReturnAdress]];
    if (![db open]) {
        [db close];
    }
    [db open];
    success = [db executeUpdate:request];
    [db close];
    return success;
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

#pragma mark - Method working with data from servers

- (void)repackDataFromRequestClient:(id)resultData fromServer:(ServerNameEnum)serverName {
    
    NSArray *responseArray = [NSArray new];
    NSDictionary *responseDictionary = [NSDictionary new];
    NSMutableArray* queryArray = [NSMutableArray new];
    ObjClient *objClient = [ObjClient new];
    
    switch (serverName) {
            
        case Gov: {
            
            if ([resultData isKindOfClass:[NSArray class]]) {
                responseArray = resultData;
            }
            if ([responseArray count] != 0) {
                NSLog(@"Array is full. Gov server works.");
                
                [responseArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *dict = obj;
                    //NSLog(@"%@", dict);
                    NSString *shortCurName = [dict objectForKey:@"cc"];
                    double rate = [[dict objectForKey:@"rate"] doubleValue];
                    //NSString *fullName = [dict objectForKey:@"txt"];
                    NSString *fullName = @"";
                    NSString *insertQueue = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CurrencyRate VALUES (\'%@\', %f, \'%@\')", shortCurName, rate, fullName];
                    [queryArray addObject:insertQueue];
                    
                }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationAboutLoadingGovData object:nil];
                
                NSArray *fullQueryArray = [NSArray arrayWithArray:queryArray];
                [objClient writeWithTransactionRequestToDatabase:fullQueryArray];
                
            } else {
                NSLog(@"Array is empty. Problem with Gov server.");
            }
            
            break;
        }
            
        case Yahoo: {
            
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                responseDictionary = resultData;
            }
            if ([responseDictionary count] != 0) {
                NSLog(@"Dictionary is full. Yahoo server works.");
                
                NSDictionary *queryDict = [responseDictionary objectForKey:@"query"];
                NSDictionary *resultDict = [queryDict objectForKey:@"results"];
                NSArray *rateArray = [resultDict objectForKey:@"rate"];
                
                [rateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSDictionary *dict = obj;
                    //NSLog(@"%@", dict);
                    NSString *pairCurName = [dict objectForKey:@"Name"];
                    double rate = [[dict objectForKey:@"Rate"] doubleValue];
                    double ask = [[dict objectForKey:@"Ask"] doubleValue];
                    double bid = [[dict objectForKey:@"Bid"] doubleValue];
                    //NSLog(@"%@, %f, %f, %f", pairCurName, rate, ask, bid);
                    NSString *insertQueue = [NSString stringWithFormat:@"INSERT OR REPLACE INTO yahooCurrencyRate VALUES (\'%@\', %f, %f, %f)", pairCurName, rate, ask, bid];
                    [queryArray addObject:insertQueue];
                    
                }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationAboutLoadingYahooData object:nil];
                
                NSArray *fullQueryArray = [NSArray arrayWithArray:queryArray];
                [objClient writeWithTransactionRequestToDatabase:fullQueryArray];
                
            } else {
                NSLog(@"Dictionary is empty. Problem with Yahoo server.");
            }
            
            break;
        }
            
        case BrentStock: {
            
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                responseDictionary = resultData;
            }
            if ([responseDictionary count] != 0) {
                NSLog(@"Dictionary is full. BrentStocks server works.");
            
                NSArray *brentArray = [responseDictionary objectForKey:@"data"];
                NSArray *dataArray = [brentArray firstObject];
                double rate = [[dataArray objectAtIndex:4] doubleValue];
                [[NSUserDefaults standardUserDefaults] setDouble:rate forKey:BrentStockKey];
                
            } else {
                NSLog(@"Dictionary is empty. Problem with Yahoo server.");
            }

            break;
        }
            
        default:
            NSLog(@"Unknown server!");
            break;
            
    }
    
}

@end


