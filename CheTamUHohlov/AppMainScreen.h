//
//  AppScreenViewController.h
//  CheTamUHohlov
//
//  Created by Admin on 27.02.16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheTamUHohlov-Swift.h"
@import GoogleMobileAds;
@class BackgroundView;

@interface AppMainScreen : UIViewController

@property (weak, nonatomic) IBOutlet BackgroundView *background;

@property (strong, nonatomic) UILabel *headLabel;

@property (strong, nonatomic) UILabel *curToDollarLabel;
@property (strong, nonatomic) UILabel *curToEuroLabel;
@property (strong, nonatomic) UILabel *specialProductLabel;

@property (strong, nonatomic) UILabel *curToDollar;
@property (strong, nonatomic) UILabel *curToEuro;
@property (strong, nonatomic) UILabel *productPrice;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (strong, nonatomic) GoodButton *healButton;
@property (strong, nonatomic) GoodButton *homeButton;

- (void)healAction:(GoodButton *)sender;
- (void)homeButton:(GoodButton *)sender;

@end
