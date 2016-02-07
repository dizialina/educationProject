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
    
    //проверка количества файлов в папке Documents (в старом варианте равна 0)
    //NSArray* listFilesInTemp = [manager contentsOfDirectoryAtPath:pathDocumentsFolder error:nil];
    //NSLog(@"%@", listFilesInTemp);    
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

#pragma mark - Transaction Method

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
            [db executeQuery:request];
        }
        [db commit];
        [db close];
        return YES;
    }
    return NO;
}



@end

// пример который х пойми как работает

//char *insertTermError;
//sqlite3_exec(dbMaster, "BEGIN TRANSACTION", NULL, NULL, &insertTermError);
//
//char buffer[] = "INSERT OR IGNORE INTO Records (Name, Address, EmailAddress, OrderID, PaymentID) VALUES (?1, ?2, ?3, ?4, ?5)";
//sqlite3_stmt *insertTermStatement;
//sqlite3_prepare_v2(dbMaster, buffer, strlen(buffer), &insertTermStatement, NULL);
//
//for (unsigned i = 0; i < recordCount; i++)
//{
//    NSString *name = getName(i);
//    NSString *address = getAddress(i);
//    NSString *emailAddress = getEmailAddress(i);
//    
//    sqlite3_bind_text(insertTermStatement, 1, name.c_str(), name.size(), SQLITE_STATIC);
//    sqlite3_bind_text(insertTermStatement, 2, address.c_str(), address.size());
//    sqlite3_bind_text(insertTermStatement, 3, emailAddress.c_str(), emailAddress.size(), SQLITE_STATIC);
//    sqlite3_bind_int(insertTermStatement, 4, getOrderID(i));
//    sqlite3_bind_int(insertTermStatement, 5, getPaymentID(i));
//    
//    if (sqlite3_step(insertTermStatement) != SQLITE_DONE)
//    {
//        NSLog(@"Commit failed");
//    }
//    
//    sqlite3_reset(insertTermStatement);
//}
//
//sqlite3_exec(dbMaster, "COMMIT TRANSACTION", NULL, NULL, &insertTermError);
//sqlite3_finalize(insertTermStatement);
