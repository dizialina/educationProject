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

@implementation ObjClient {
    sqlite3 *database;
}

#pragma mark - Main Methods

- (NSString *)copyDBFileToPath {
    
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

- (BOOL)writeRequestIntoDB:(NSString *)request {
    
    @synchronized(self) {

    //NSLog(@"Request to be executed:%@",request);
    BOOL returnBool = NO;
    NSString *stringDBPath = [self copyDBFileToPath];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK ) {
        const char *receivedRequest = [request UTF8String];
        sqlite3_stmt *writeStatement = nil;
        if(sqlite3_prepare_v2(database, receivedRequest, -1, &writeStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        }
        if (SQLITE_DONE != sqlite3_step(writeStatement)){
            NSAssert1(0, @"Error while creating database. '%s'", sqlite3_errmsg(database));
        }
        returnBool = YES;
        sqlite3_reset(writeStatement);
        sqlite3_finalize(writeStatement);
    } else {
        NSAssert1(0, @"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    sqlite3_close(database);

    return returnBool;
        
    }
}

- (NSArray *)returnCurrencyRateObjectArrayFromGovDB:(NSString *)request {
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    NSString *stringDBPath = [self copyDBFileToPath];
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
    NSString *stringDBPath = [self copyDBFileToPath];
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
    NSString *stringDBPath = [self copyDBFileToPath];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK) {
        returnBool = YES; }
    return returnBool;
}

- (void)closeDB {
    sqlite3_close(database);
}

- (BOOL)writeRequestIntoDBWithTransaction:(NSArray *)arrayItem {

    //NSLog(@"Request to be executed:%@",request);
    
    BOOL returnBool = NO;
    NSString *stringDBPath = [self copyDBFileToPath];
    
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK ) {
    
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
        sqlite3_stmt *insertTermStatement = NULL;
    
        for (unsigned i = 0; i < arrayItem.count; i++)
        {
            // http://stackoverflow.com/questions/12133355/sqlite-transaction-syntax-for-ios
            // "Your code can be a bit more efficient if you !!!MOVE THE PREPARE OUTSIDE THE LOOP!!!. If you do this, use sqlite3_reset inside the loop, and sqlite3_finalize after the loop."
            // Как для эффективности поместить PREPARE снаружи цикла, если он принимает наш string запрос из массива и этот запрос каждый раз разный?
            
            const char *buffer = [[arrayItem objectAtIndex:i] UTF8String];
            if (sqlite3_prepare_v2(database, buffer, -1, &insertTermStatement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
            }
            if (sqlite3_step(insertTermStatement) != SQLITE_DONE) {
                NSLog(@"Step. DB not updated. Error: %s",sqlite3_errmsg(database));
            }
            if (sqlite3_reset(insertTermStatement) != SQLITE_OK) {
                NSLog(@"Reset. SQL Error: %s",sqlite3_errmsg(database));
            }
        }
    
        if (sqlite3_finalize(insertTermStatement) != SQLITE_OK) {
            NSLog(@"Finalize. SQL Error: %s", sqlite3_errmsg(database));
        }
        if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) {
            NSLog(@"Commit. SQL Error: %s",sqlite3_errmsg(database));
        }
        
    } else {
        NSAssert1(0, @"Error while opening database '%s'", sqlite3_errmsg(database));
    }
    
    return returnBool;
    
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
