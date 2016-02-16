//
//  RequestClient.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjClient.h"

@interface RequestClient : NSObject

+ (void)requestDataFromServer;
+ (void)requestDataFromServerWithUrl:(NSString *)urlString fromServer:(ServerNameEnum)serverName;

@end
