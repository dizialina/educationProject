//
//  ViewController.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheTamUHohlov-Swift.h"
@import GoogleMobileAds;

@interface MainScreen : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageTag;


@property (weak, nonatomic) IBOutlet UILabel *curToDollarLabel;
@property (weak, nonatomic) IBOutlet UILabel *curToEuroLabel;
@property (weak, nonatomic) IBOutlet UILabel *specialProductLabel;

@property (weak, nonatomic) IBOutlet UILabel *curToDollar;
@property (weak, nonatomic) IBOutlet UILabel *curToEuro;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet GoodButton *healButton;
@property (weak, nonatomic) IBOutlet GoodButton *homeButton;

- (IBAction)healAction:(GoodButton *)sender;
- (IBAction)homeButton:(GoodButton *)sender;

@end

