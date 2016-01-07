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
        
        NSArray *myArray = @[@1,@2,@4,@8,@5,@[@1,@2,@5,@6,@7,@[@1,@1,@34,@56,@7]]];
        
        NSArray *newArray = [[myArray objectAtIndex:5] objectAtIndex:5];
        NSLog(@"%@",newArray);
        
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"%@", response);
            
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
