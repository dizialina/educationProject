//
//  RequestClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestClient : NSObject

+ (void)requestDataFromGovServer:(NSString *) urlString;
+ (void)requestDataFromYahooServer:(NSString *) urlString;
+ (void)requestDataFromGovServerAndSaveWithTransaction:(NSString *) urlString;

@end
