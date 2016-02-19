//
//  DBClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RateItemFromGov;

typedef enum serverName {
    Gov,
    Yahoo,
    BrentStock
} ServerNameEnum ;


@interface ObjClient : NSObject

- (NSString *)copyDBFileToPathIfNotExistsAndReturnAdress;

- (BOOL)writeWithTransactionRequestToDatabase:(NSArray*)arrayRequests;
- (BOOL)writeRequestToDatabase:(NSString*)request;

- (NSArray *)returnCurrencyRateObjectArrayFromGovDBWithFMDB:(NSString *)request;
- (NSArray *)returnCurrencyRateObjectArrayFromYahooBDWithFMDB:(NSString *)request;

- (BOOL)openDB;
- (void)closeDB;

- (void)repackDataFromRequestClient:(id)resultData fromServer:(ServerNameEnum)serverName;

@end
