//
//  ViewController.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "MainScreen.h"
#import "ObjClient.h"
#import "RequestClient.h"
#import "RateItemFromGov.h"
#import "RateItemFromYahoo.h"
#import "Constants.h"
#import "CheTamUHohlov-Swift.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "FunnyJokesClass.h"
@import GoogleMobileAds;

@interface MainScreen () {
    NSMutableDictionary *dataDictUkr;
    NSMutableDictionary *dataDictRus;
    int currentItem;
    BOOL randomJoke;
    BOOL russianMode;
}

@property (strong, nonatomic) NSArray *curRateObjYahoo;
@property (strong, nonatomic) NSArray *receiveData;

@end

@implementation MainScreen {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateDataInView];
        
    currentItem = 0;
    randomJoke = NO;
    russianMode = NO;
   
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    
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
    NSLog(@"%f", self.view.frame.size.height);
}

- (void)updateDataInView {
    
    ObjClient *objClient = [ObjClient new];
    
//    //NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate WHERE Name=\'%@\'", @"USD/RUB"];
//    NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate"];
//    NSArray *testResultArray = [objClient returnCurrencyRateObjectArrayFromYahooBD:testSelectQueue];
//    NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
//    if (testResultArray.count != 0) {
//        self.curRateObj = testResultArray;
//    
//    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        dataDictUkr = [NSMutableDictionary new];
        NSString *selectQueueUSD = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"USD"];
        NSArray *resultArrayUSD = [objClient returnCurrencyRateObjectArrayFromGovDB:selectQueueUSD];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArrayUSD count]);
        if (resultArrayUSD.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayUSD firstObject];
                self.curToDollar.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                self.productPrice.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate * 2.1];
                [dataDictUkr setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"USD"];
            });
        }
        
        NSString *selectQueueEUR = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"EUR"];
        NSArray *resultArrayEUR = [objClient returnCurrencyRateObjectArrayFromGovDB:selectQueueEUR];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArrayEUR count]);
        if (resultArrayEUR.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayEUR firstObject];
                self.curToEuro.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                [dataDictUkr setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"EUR"];

            });
        }
        
        dataDictRus = [NSMutableDictionary new];
        NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate"];
        NSArray *testResultArray = [objClient returnCurrencyRateObjectArrayFromYahooBD:testSelectQueue];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
        if (testResultArray.count != 0) {
            self.curRateObjYahoo = testResultArray;
            RateItemFromYahoo *rubToDollarItem = [self.curRateObjYahoo firstObject];
            RateItemFromYahoo *rubToEuroItem = [self.curRateObjYahoo lastObject];
            
//            NSLog(@"%@", rubToDollarItem.pairCurName);
//            NSLog(@"%f", rubToDollarItem.rate);
//            NSLog(@"%f", rubToDollarItem.ask);
//            NSLog(@"%f", rubToDollarItem.bid);
            
            [dataDictRus setObject:[NSNumber numberWithDouble:rubToDollarItem.rate] forKey:@"USD"];
            [dataDictRus setObject:[NSNumber numberWithDouble:rubToEuroItem.rate] forKey:@"EUR"];
        }

        
    });
    
    
}

#pragma mark - Button Actions

- (IBAction)healAction:(GoodButton *)sender {
    
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
            
            if (!russianMode) {
                currentItem = arc4random_uniform(42);
            } else {
                currentItem = arc4random_uniform(15);
            }

        }
        
    } else {
        currentItem = 0;
        randomJoke = YES;
        [self healAction: sender];
    }
    
    
}

- (IBAction)homeButton:(GoodButton *)sender {
    
    if (!russianMode) {
        
        russianMode = YES;
        
        [self.homeButton setTitle:@"Че там у хохлов?" forState:UIControlStateNormal];
        self.headLabel.text = @"Че там в раше?";
        
        RateItemFromYahoo *rubToDollarItem = [self.curRateObjYahoo firstObject];
        RateItemFromYahoo *rubToEuroItem = [self.curRateObjYahoo lastObject];
        
        self.curToDollarLabel.text = @"рублей за доллар";
        self.curToDollar.text = [NSString stringWithFormat:@"%.2f", rubToDollarItem.rate];
        self.curToEuroLabel.text = @"рублей за евро";
        self.curToEuro.text = [NSString stringWithFormat:@"%.2f", rubToEuroItem.rate];
        self.specialProductLabel.text = @"за баррель";
        self.productPrice.text = @"no data"; // цена за нефть
        
    } else {
        
        russianMode = NO;
        
        [self.homeButton setTitle:@"Че там в раше?" forState:UIControlStateNormal];
        self.headLabel.text = @"Че там у хохлов?";
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
