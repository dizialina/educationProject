//
//  RequestClient.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "RequestClient.h"
#import "ObjClient.h"


@implementation RequestClient

#pragma mark - Main Methods

+ (void)requestDataFromServer:(NSString *) urlString {
    
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
                    [responseArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *dict = obj;
                        //NSLog(@"%@", dict);
                        NSString *shortCurName = [dict objectForKey:@"cc"];
                        double rate = [[dict objectForKey:@"rate"] doubleValue];
                        NSString *fullName = @"";//[dict objectForKey:@"txt"];
//                        NSString *newFullName = [fullName stringByReplacingOccurrencesOfString:@"(" withString:@""];
//                        NSString *newFullName2 = [newFullName stringByReplacingOccurrencesOfString:@")" withString:@""];
                        
                        NSString *insertQueue = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CurrencyRate VALUES (\'%@\', %f, \'%@\')",shortCurName, rate, fullName];
                        ObjClient *objClient = [ObjClient new];
                        [objClient writeRequestIntoDB:insertQueue];
                        
                    }];
                } else {
                    NSLog(@"Array is empty");
                }
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
            
        }] resume];
        
    }
}

#pragma mark - Methods working with Yahoo server

+ (void)testRequestDataFromServer:(NSString *) urlString { //тестовый(удалить)
        
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
                        NSLog(@"%@, %f, %f, %f", pairCurName, rate, ask, bid);
                        NSString *insertQueue = [NSString stringWithFormat:@"INSERT OR REPLACE INTO yahooCurrencyRate VALUES (\'%@\', %f, %f, %f)", pairCurName, rate, ask, bid];
                        ObjClient *objClient = [ObjClient new];
                        [objClient writeRequestIntoDB:insertQueue];
                            
                    }];
                
                } else {
                    NSLog(@"Test Dictionary is empty");
                }
            
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
                
        }] resume];
        
    }
}

#pragma mark - Test Transaction Method

+ (void)secondTestRequestDataFromServer:(NSString *) urlString {
    
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
                    
                    NSLog(@"Array was done");
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
                    [objClient openDB];
                    [objClient testWriteRequestIntoDB:fullQueryArray];
                    [objClient closeDB];
                    
                } else {
                    NSLog(@"Array is empty");
                }
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
            
        }] resume];
        
    }
}




@end
