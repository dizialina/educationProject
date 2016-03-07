//
//  AppScreenViewController.m
//  CheTamUHohlov
//
//  Created by Admin on 27.02.16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "AppMainScreen.h"
#import "ObjClient.h"
#import "RequestClient.h"
#import "RateItemFromGov.h"
#import "RateItemFromYahoo.h"
#import "Constants.h"
#import "Keys.h"
#import "CheTamUHohlov-Swift.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "FunnyJokesClass.h"
#import "BackgroundView.h"
@import GoogleMobileAds;

@interface AppMainScreen () {
    
    NSMutableDictionary *dataDictUkr;
    NSMutableDictionary *dataDictRus;
    int currentItem;
    BOOL randomJoke;
    BOOL russianMode;
    
}

@property (strong, nonatomic) NSArray *curRateObjYahoo;
@property (strong, nonatomic) NSArray *receiveData;

@end

@implementation AppMainScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateDataInView];
    
    currentItem = 0;
    randomJoke = NO;
    russianMode = NO;
    
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = GoogleBannerKey;
    self.bannerView.rootViewController = self;
    GADRequest *someRequest = [GADRequest request];
    someRequest.testDevices = @[ kGADSimulatorID ];
    [self.bannerView loadRequest:someRequest];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataInView)
                                                 name:NotificationAboutLoadingGovData
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataInView)
                                                 name:NotificationAboutLoadingYahooData
                                               object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.healButton = [[GoodButton alloc] initWithFrame:self.background.healButton];
    self.homeButton = [[GoodButton alloc] initWithFrame:self.background.homeButton];
    [self.healButton setTitle:@"Приложить подорожник" forState:UIControlStateNormal];
    [self.homeButton setTitle:@"Че там в раше?" forState:UIControlStateNormal];
    [self setButtonsAttributes:self.healButton];
    [self setButtonsAttributes:self.homeButton];
    [self.healButton addTarget:self action:@selector(healAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.homeButton addTarget:self action:@selector(homeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.headLabel = [[UILabel alloc] initWithFrame:self.background.headerLabel];
    self.headLabel.textColor = [UIColor whiteColor];
    self.headLabel.textAlignment = NSTextAlignmentCenter;
    self.headLabel.font = [UIFont fontWithName:@"Natasha" size:36];
    self.headLabel.text = @"#четамвукраине";
    self.headLabel.adjustsFontSizeToFitWidth = YES;
    self.headLabel.minimumScaleFactor = 0.2;
    self.headLabel.numberOfLines = 0;
    
    self.curToDollarLabel = [[UILabel alloc] initWithFrame:self.background.usdLabel];
    [self setLowerLabelsAttributes:self.curToDollarLabel];
    self.curToDollarLabel.text = @"грн за доллар";
    self.curToDollar = [[UILabel alloc] initWithFrame:self.background.usdPrice];
    self.curToDollar.textColor = [UIColor whiteColor];
    [self setUpperLabelsAttributes:self.curToDollar];
    
    self.curToEuroLabel = [[UILabel alloc] initWithFrame:self.background.eurLabel];
    [self setLowerLabelsAttributes:self.curToEuroLabel];
    self.curToEuroLabel.text = @"грн за евро";
    self.curToEuro = [[UILabel alloc] initWithFrame:self.background.eurPrice];
    self.curToEuro.textColor = [UIColor whiteColor];
    [self setUpperLabelsAttributes:self.curToEuro];
    
    self.specialProductLabel = [[UILabel alloc] initWithFrame:self.background.productLabel];
    [self setLowerLabelsAttributes:self.specialProductLabel];
    self.specialProductLabel.text = @"за 1 кг сала";
    self.productPrice = [[UILabel alloc] initWithFrame:self.background.productPrice];
    self.productPrice.textColor = [UIColor colorWithRed:0.819608 green:0.211765 blue:0.192157 alpha:1.0];
    [self setUpperLabelsAttributes:self.productPrice];
    
    NSArray *array = [NSArray arrayWithObjects:self.specialProductLabel, self.productPrice, self.healButton, self.homeButton, self.headLabel, self.curToDollarLabel, self.curToDollar, self.curToEuroLabel, self.curToEuro, nil];
    
    for (id obj in array) {
        [self.background addSubview:obj];
    }

    
}

- (void)updateDataInView {
    
    ObjClient *objClient = [ObjClient new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        dataDictUkr = [NSMutableDictionary new];
        NSString *selectQueueUSD = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"USD"];
        NSArray *resultArrayUSD = [objClient returnCurrencyRateObjectArrayFromGovDBWithFMDB:selectQueueUSD];
        NSLog(@"Gov: Count of items in result array after SELECT USD queue: %lu", (unsigned long)[resultArrayUSD count]);
        if (resultArrayUSD.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayUSD firstObject];
                self.curToDollar.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                self.productPrice.text = [NSString stringWithFormat:@"%.2f₴", bankRateItem.rate * 2.1];
                [dataDictUkr setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"USD"];
            });
        }
        
        NSString *selectQueueEUR = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"EUR"];
        NSArray *resultArrayEUR = [objClient returnCurrencyRateObjectArrayFromGovDBWithFMDB:selectQueueEUR];
        NSLog(@"Gov: Count of items in result array after SELECT EUR queue: %lu", (unsigned long)[resultArrayEUR count]);
        if (resultArrayEUR.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayEUR firstObject];
                self.curToEuro.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                [dataDictUkr setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"EUR"];
                
            });
        }
        
        dataDictRus = [NSMutableDictionary new];
        NSString *selectQueueYahoo = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate"];
        NSArray *resultArrayYahoo = [objClient returnCurrencyRateObjectArrayFromYahooBDWithFMDB:selectQueueYahoo];
        NSLog(@"Yahoo: Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArrayYahoo count]);
        if (resultArrayYahoo.count != 0) {
            self.curRateObjYahoo = resultArrayYahoo;
            RateItemFromYahoo *rubToDollarItem = [self.curRateObjYahoo firstObject];
            RateItemFromYahoo *rubToEuroItem = [self.curRateObjYahoo lastObject];
            [dataDictRus setObject:[NSNumber numberWithDouble:rubToDollarItem.rate] forKey:@"USD"];
            [dataDictRus setObject:[NSNumber numberWithDouble:rubToEuroItem.rate] forKey:@"EUR"];
        }
        
        
    });
    
    
}

#pragma mark - Private Methods

- (void) setButtonsAttributes:(GoodButton*) button {
    button.titleLabel.font = [UIFont fontWithName:@"Natasha" size:18];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.cornerRadius = 7;
    button.highlightedBackgroundColor = [UIColor colorWithRed:0.819608 green:0.211765 blue:0.192157 alpha:1.0];
    button.nonHighlightedBackgroundColor = [UIColor clearColor];
}

- (void) setLowerLabelsAttributes:(UILabel*) label {
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Natasha" size:20];
}

- (void) setUpperLabelsAttributes:(UILabel*) label {
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Natasha" size:41];
    label.text = @"NO DATA";
}

#pragma mark - Button Actions

- (void)healAction:(GoodButton *)sender {
    
    FunnyJokesClass *jokes = [FunnyJokesClass new];
    NSArray *jokesArray;
    NSDictionary *dataDict;
    
    if (!russianMode) {
        jokesArray = [jokes returnArrayWithJokesFor:Ukraine];
        dataDict = [NSDictionary dictionaryWithDictionary:dataDictUkr];
    } else {
        jokesArray = [jokes returnArrayWithJokesFor:Russia];
        dataDict = [NSDictionary dictionaryWithDictionary:dataDictRus];
    }
    
    if (currentItem < [jokesArray count]) {
        NSDictionary *joke = [jokesArray objectAtIndex:currentItem];
        
        if ([[joke objectForKey:@"type"] isEqualToString:@"Multiply"]) {
            double multiply = [[joke objectForKey:@"amount"] doubleValue];
            self.curToDollar.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"USD"] doubleValue] * multiply];
            self.curToEuro.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"EUR"] doubleValue] * multiply];
            self.headLabel.text = [joke objectForKey:@"joke"];
            
        } else if ([[joke objectForKey:@"type"] isEqualToString:@"Divide"]) {
            double divide = [[joke objectForKey:@"amount"] doubleValue];
            self.curToDollar.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"USD"] doubleValue] / divide];
            self.curToEuro.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"EUR"] doubleValue] / divide];
            self.headLabel.text = [joke objectForKey:@"joke"];
            
        } else {
            self.curToDollar.text = [NSString stringWithFormat:@"%@", [joke objectForKey:@"amount"]];
            self.curToEuro.text = [NSString stringWithFormat:@"%@", [joke objectForKey:@"amount"]];
            self.headLabel.text = [joke objectForKey:@"joke"];
            
        }
        
        if (!randomJoke) {
            
            currentItem += 1;
            
        } else {
            currentItem = arc4random_uniform((unsigned int)jokesArray.count);
        }
        
    } else {
        currentItem = 0;
        randomJoke = YES;
        [self healAction: sender];
    }
    
    
}



- (void)homeButton:(GoodButton *)sender {
    
    currentItem = 0;
    
    if (!russianMode) {
        
        russianMode = YES;
        
        [self.homeButton setTitle:@"Че там в украине?" forState:UIControlStateNormal];
        self.headLabel.text = @"#четамвраше";
        
        RateItemFromYahoo *rubToDollarItem = [self.curRateObjYahoo firstObject];
        RateItemFromYahoo *rubToEuroItem = [self.curRateObjYahoo lastObject];
        
        self.curToDollarLabel.text = @"руб за доллар";
        self.curToDollar.text = [NSString stringWithFormat:@"%.2f", rubToDollarItem.rate];
        self.curToEuroLabel.text = @"руб за евро";
        self.curToEuro.text = [NSString stringWithFormat:@"%.2f", rubToEuroItem.rate];
        self.specialProductLabel.text = @"за баррель";
        if ([[NSUserDefaults standardUserDefaults] doubleForKey:BrentStockKey]) {
            self.productPrice.text = [NSString stringWithFormat:@"%.2f$", [[NSUserDefaults standardUserDefaults] doubleForKey:BrentStockKey]];
            
        } else {
            self.productPrice.text = @"NO DATA";
        }
        
    } else {
        
        russianMode = NO;
        
        [self.homeButton setTitle:@"Че там в раше?" forState:UIControlStateNormal];
        self.headLabel.text = @"#четамвукраине";
        self.curToDollarLabel.text = @"грн за доллар";
        self.curToEuroLabel.text = @"грн за евро";
        self.specialProductLabel.text = @"за 1 кг сала";
        
        [self updateDataInView];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
