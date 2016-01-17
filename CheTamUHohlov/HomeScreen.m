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
    
    self.rubToDollar.text = [NSString stringWithFormat:@"%f", self.curRateObj.ask];
}

@end
