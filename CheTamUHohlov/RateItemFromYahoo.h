//
//  TestCurRateObj.h
//  CheTamUHohlov
//
//  Created by Admin on 14.01.16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateItemFromYahoo : NSObject

@property (nonatomic, strong) NSString *pairCurName;
@property (nonatomic, assign) double rate;
@property (nonatomic, assign) double ask;
@property (nonatomic, assign) double bid;

@end
