//
//  DBClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RateItemFromGov;

@interface ObjClient : NSObject

- (NSString *)copyDBFileToPath;

- (BOOL)writeRequestIntoDB:(NSString *)request;

- (NSArray *)returnCurrencyRateObjectArrayFromGovDB:(NSString *)request;
- (NSArray *)returnCurrencyRateObjectArrayFromYahooBD:(NSString *)request;

- (BOOL)openDB;
- (void)closeDB;
- (BOOL)writeRequestIntoDBWithTransaction:(NSArray *)arrayItem;

@end
