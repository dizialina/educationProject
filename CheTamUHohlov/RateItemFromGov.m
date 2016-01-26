//
//  BankRateItem.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "RateItemFromGov.h"

@implementation RateItemFromGov
@synthesize testProperty = _testProperty;


- (void)setTestProperty:(NSString *)testProperty {
    @synchronized(self) {
        _testProperty = testProperty;
    }
    
}

- (NSString *) testProperty {
    return _testProperty;
}

@end
