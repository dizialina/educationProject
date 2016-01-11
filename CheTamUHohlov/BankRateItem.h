//
//  BankRateItem.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BankRateItem : NSObject

@property (nonatomic, strong) NSString *shortCurName;
@property (nonatomic, assign) double rate;
@property (nonatomic, strong) NSString *fullName;


@property (atomic, strong) NSString* testProperty;


@end
