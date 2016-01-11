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
#import "BankRateItem.h"

@implementation ObjClient {
    sqlite3 *database;
}

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

- (NSArray *)returnCurrencyRateObjectArray:(NSString *)request {
    
    NSMutableArray *currencyRateArray = [NSMutableArray new];
    NSString *stringDBPath = [self copyDBFileToPath];
    if (sqlite3_open([stringDBPath UTF8String], &database) == SQLITE_OK) {
        const char *receivedRequest = [request UTF8String];
        sqlite3_stmt *readStatement = nil;
        if(sqlite3_prepare_v2(database, receivedRequest, -1, &readStatement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error while reading statement. '%s'", sqlite3_errmsg(database));
        }
        while (sqlite3_step(readStatement) == SQLITE_ROW) {
            BankRateItem *bankItem = [BankRateItem new];
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

@end
