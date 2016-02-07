//
//  RequestClient.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "RequestClient.h"
#import "ObjClient.h"
#import "Constants.h"
#import "Keys.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>


@implementation RequestClient

+ (void)requestDataFromServer {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateForm = [NSDateFormatter new];
    [dateForm setDateFormat:@"EEE"];
    NSString *dayOfWeek = [dateForm stringFromDate:date];
    
    NSString *urlGov;
    
    if ([dayOfWeek isEqualToString:@"Sat"]) {
        
        NSDate *newDate = [date dateByAddingTimeInterval:-86400]; //минус сутки
        [dateForm setDateFormat:@"yyyyMMdd"];
        NSString *currentDate = [dateForm stringFromDate:newDate];
        urlGov = [NSString stringWithFormat:@"http://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=%@&json", currentDate];
        //NSLog(urlGov);
        
    } else if ([dayOfWeek isEqualToString:@"Sun"]) {
        
        NSDate *newDate = [date dateByAddingTimeInterval:-172800]; //минус двое суток
        [dateForm setDateFormat:@"yyyyMMdd"];
        NSString *currentDate = [dateForm stringFromDate:newDate];
        urlGov = [NSString stringWithFormat:@"http://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=%@&json", currentDate];
        //NSLog(urlGov);
        
    } else {
        urlGov = LinkToGovData;
        //NSLog(urlGov);
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self requestDataFromGovServerAndSaveWithTransaction:urlGov];
        [self requestDataFromYahooServer:LinkToYahooData];
        [self requestDataFromBrentStocks:LinkToBrentStocks];
    });
    
}

#pragma mark - Methods working with Yahoo server

+ (void)requestDataFromYahooServer:(NSString *) urlString {
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    if(remoteHostStatus != NotReachable) {
        
        if (urlString.length != 0) {
            
            NSURL *url = [NSURL URLWithString:urlString];
        
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
            [urlRequest setURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                assert(data);
                if (!error) {
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
                            NSArray *requestsArray = @[insertQueue];
                            ObjClient *objClient = [ObjClient new];
                            [objClient writeWithTransactionRequestToDatabase:requestsArray];
                            
                        }];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationAboutLoadingYahooData object:nil];
                
                    } else {
                        NSLog(@"Dictionary is empty. Problem with Yahoo server.");
                    }
            
                } else {
                    NSLog(@"%@",error.localizedDescription);
                }
                
            }] resume];
            
        }

    } else {
        NSLog(@"UNREACHABLE!");
    }
}

#pragma mark - Transaction Method working with Gov server

+ (void)requestDataFromGovServerAndSaveWithTransaction:(NSString *) urlString {
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    if(remoteHostStatus != NotReachable) {
    
        if (urlString.length != 0) {
        
            NSURL *url = [NSURL URLWithString:urlString];
        
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
            [urlRequest setURL:url];
            [urlRequest setHTTPMethod:@"GET"];
        
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
                assert(data);
                if (!error) {
                    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if ([responseArray count] != 0) {
                    
                        NSLog(@"Array is full. Gov server works.");
                        NSMutableArray* queryArray = [NSMutableArray new];
                        [responseArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSDictionary *dict = obj;
                            //NSLog(@"%@", dict);
                            NSString *shortCurName = [dict objectForKey:@"cc"];
                            double rate = [[dict objectForKey:@"rate"] doubleValue];
                            NSString *fullName = [dict objectForKey:@"txt"];
                            //NSString *fullName = @"";
                            NSString *insertQueue = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CurrencyRate VALUES (\'%@\', %f, \'%@\')", shortCurName, rate, fullName];
                            [queryArray addObject:insertQueue];
                        
                        }];
                    
                        NSArray *fullQueryArray = [NSArray arrayWithArray:queryArray];
                        ObjClient *objClient = [ObjClient new];
                        [objClient writeWithTransactionRequestToDatabase:fullQueryArray];
                    
                    } else {
                        NSLog(@"Array is empty");
                    }
                } else {
                    NSLog(@"%@",error.localizedDescription);
                }
            
            }] resume];
        
        }
        
    } else {
        NSLog(@"UNREACHABLE!");
    }
}

+ (void) requestDataFromBrentStocks:(NSString *) urlString {
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    NetworkStatus remoteHostStatus = [reach currentReachabilityStatus];
    if(remoteHostStatus != NotReachable) {
        
        if (urlString.length != 0) {
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
            [urlRequest setURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                assert(data);
                if (!error) {
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if ([responseDictionary count] != 0) {
                        
                        NSLog(@"Dictionary is full. BrentStocks server works.");
                        //NSLog(@"%@", responseDictionary);
                        NSArray *queryArray = [responseDictionary objectForKey:@"data"];
                        NSArray *dataArray = [queryArray firstObject];
                        double rate = [[dataArray objectAtIndex:4] doubleValue];
                        [[NSUserDefaults standardUserDefaults] setDouble:rate forKey:BrentStockKey];
                    }
                }
            }] resume];
            
        }
    }
}






@end
