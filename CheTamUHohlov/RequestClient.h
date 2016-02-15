//
//  RequestClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestClient : NSObject

+ (void)requestDataFromYahooServer:(NSString *) urlString;
+ (void)requestDataFromGovServerAndSaveWithTransaction:(NSString *) urlString;
+ (void)requestDataFromServer;
+ (void)requestDataFromBrentStocks:(NSString *) urlString;

@end
