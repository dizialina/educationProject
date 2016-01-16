//
//  DBClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BankRateItem;

@interface ObjClient : NSObject

- (NSString *)copyDBFileToPath;

- (BOOL)writeRequestIntoDB:(NSString *)request;
- (NSArray *)returnCurrencyRateObjectArray:(NSString *)request;

- (NSArray *)testReturnCurrencyRateObjectArray:(NSString *)request; //тестовый(удалить)
- (BOOL)testWriteRequestIntoDB:(NSArray *)arrayItem; //тестовый(удалить)
- (BOOL)openDB;
- (void)closeDB;

@end
