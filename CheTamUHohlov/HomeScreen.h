//
//  HomeScreen.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/17/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateItemFromYahoo.h"

@interface HomeScreen : UIViewController

@property (strong, nonatomic) NSArray *curRateObj;
@property (weak, nonatomic) IBOutlet UILabel *rubToDollar;
@property (weak, nonatomic) IBOutlet UILabel *rubToEuro;
@property (weak, nonatomic) IBOutlet UILabel *askDollar;
@property (weak, nonatomic) IBOutlet UILabel *askEuro;
@property (weak, nonatomic) IBOutlet UILabel *bidDollar;
@property (weak, nonatomic) IBOutlet UILabel *bidEuro;

@end
