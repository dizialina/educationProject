//
//  RequestClient.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "RequestClient.h"

@implementation RequestClient

+ (void)requestDataFromServer:(NSString *) urlString {
    
    if (urlString.length != 0) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest new];
        [urlRequest setURL:url];
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setHTTPMethod:@"appliction/json"];
        
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            assert(data);
            if (!error) {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@", responseDict);
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
            
        }] resume];
        
    }

    
}

@end
