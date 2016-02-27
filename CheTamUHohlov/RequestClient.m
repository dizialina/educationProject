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
        urlGov = [NSString stringWithFormat:@"%@%@&json", LinkToGovDataInWeekends, currentDate];
        //NSLog(urlGov);
        
    } else if ([dayOfWeek isEqualToString:@"Sun"]) {
        
        NSDate *newDate = [date dateByAddingTimeInterval:-172800]; //минус двое суток
        [dateForm setDateFormat:@"yyyyMMdd"];
        NSString *currentDate = [dateForm stringFromDate:newDate];
        urlGov = [NSString stringWithFormat:@"%@%@&json", LinkToGovDataInWeekends, currentDate];
        //NSLog(urlGov);
        
    } else {
        urlGov = LinkToGovData;
        //NSLog(urlGov);
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self requestDataFromServerWithUrl:urlGov fromServer:Gov];
        [self requestDataFromServerWithUrl:LinkToYahooData fromServer:Yahoo];
        [self requestDataFromServerWithUrl:LinkToBrentStocks fromServer:BrentStock];
    });
    
}

#pragma mark - Methods working servers

+ (void)requestDataFromServerWithUrl:(NSString *)urlString fromServer:(ServerNameEnum)serverName {
    
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
                    id resultData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    ObjClient *objClient = [ObjClient new];
                    [objClient repackDataFromRequestClient:resultData fromServer:serverName];

                } else {
                    NSLog(@"%@",error.localizedDescription);
                }
              
            }] resume];
            
        }
        
    } else {
        NSLog(@"UNREACHABLE!");
    }
}

@end
