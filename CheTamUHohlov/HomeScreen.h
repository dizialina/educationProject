//
//  HomeScreen.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/17/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestCurRateObj.h"

@interface HomeScreen : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *rubToDollar;
@property (strong, nonatomic) TestCurRateObj *curRateObj;

@end
