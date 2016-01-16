//
//  RequestClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestClient : NSObject

+ (void)requestDataFromServer:(NSString *) urlString;

+ (void)testRequestDataFromServer:(NSString *) urlString; //тестовый(удалить)
+ (void)secondTestRequestDataFromServer:(NSString *) urlString; //тестовый(удалить)

@end
