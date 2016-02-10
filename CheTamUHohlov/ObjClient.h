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

- (NSString *)copyDBFileToPathIfNotExistsAndReturnAdress;

- (BOOL) writeWithTransactionRequestToDatabase:(NSArray*)arrayRequests;

- (NSArray *)returnCurrencyRateObjectArrayFromGovDBWithFMDB:(NSString *)request;
- (NSArray *)returnCurrencyRateObjectArrayFromYahooBDWithFMDB:(NSString *)request;

- (BOOL)openDB;
- (void)closeDB;


@end
