//
//  FunnyJokesClass.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/27/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum countryType {
    Ukraine,
    Russia
} CountryTypeEnum ;


@interface FunnyJokesClass : NSObject

-(NSArray *)returnArrayWithJokesFor:(CountryTypeEnum)contryType;

@end
