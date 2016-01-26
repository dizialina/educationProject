//
//  HomeScreen.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/17/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "HomeScreen.h"

@implementation HomeScreen

-(void)viewDidLoad {
    [super viewDidLoad];
    
    RateItemFromYahoo *rubToDollarItem = [self.curRateObj firstObject];
    RateItemFromYahoo *rubToEuroItem = [self.curRateObj lastObject];
    
    self.rubToDollar.text = [NSString stringWithFormat:@"%@", rubToDollarItem.pairCurName];
    self.askDollar.text = [NSString stringWithFormat:@"%.3f", rubToDollarItem.ask];
    self.bidDollar.text = [NSString stringWithFormat:@"%.3f", rubToDollarItem.bid];
    
    self.rubToEuro.text = [NSString stringWithFormat:@"%@", rubToEuroItem.pairCurName];
    self.askEuro.text = [NSString stringWithFormat:@"%.3f", rubToEuroItem.ask];
    self.bidEuro.text = [NSString stringWithFormat:@"%.3f", rubToEuroItem.bid];
}

@end
