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
#import "HomeScreen.h"
#import "CheTamUHohlov-Swift.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "FunnyJokesClass.h"
@import GoogleMobileAds;

@interface MainScreen () {
    NSMutableDictionary *dataDict;
    int currentItem;
    BOOL randomJoke;
}

@property (strong, nonatomic) NSArray *curRateObj;
@property (strong, nonatomic) NSArray *receiveData;


@end

@implementation MainScreen {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateDataInView];
    
    if (!self.backgroundMusic) {
        NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"sunset" withExtension:@"mp3"];
        self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
        self.backgroundMusic.numberOfLoops = -1;
        self.backgroundMusic.volume = 0.3;
        [self.backgroundMusic play];
    }
    
    currentItem = 0;
    randomJoke = NO;
    //UIButton
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataInView)
                                                 name:NotificationAboutLoadingGovData
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
        dataDict = [NSMutableDictionary new];
        NSString *selectQueueUSD = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"USD"];
        NSArray *resultArrayUSD = [objClient returnCurrencyRateObjectArrayFromGovDB:selectQueueUSD];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArrayUSD count]);
        if (resultArrayUSD.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayUSD firstObject];
                self.grnToDollar.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                self.saloPrice.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate * 2.1];
                [dataDict setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"USD"];
            });
        }
        
        NSString *selectQueueEUR = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"EUR"];
        NSArray *resultArrayEUR = [objClient returnCurrencyRateObjectArrayFromGovDB:selectQueueEUR];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArrayEUR count]);
        if (resultArrayEUR.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArrayEUR firstObject];
                self.grnToEuro.text = [NSString stringWithFormat:@"%.2f", bankRateItem.rate];
                [dataDict setObject:[NSNumber numberWithDouble:bankRateItem.rate] forKey:@"EUR"];

            });
        }
        
        NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate"];
        NSArray *testResultArray = [objClient returnCurrencyRateObjectArrayFromYahooBD:testSelectQueue];
        //NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
        if (testResultArray.count != 0) {
            self.curRateObj = testResultArray;
            
        }

        
    });
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toHome"]) {
        HomeScreen *homeScreen = segue.destinationViewController;
        homeScreen.curRateObj = self.curRateObj;
        homeScreen.backgroundMusic = self.backgroundMusic;
    }
}

- (IBAction)healAction:(GoodButton *)sender {
    
    FunnyJokesClass *jokes = [FunnyJokesClass new];
    NSArray *ukraineJokes = [jokes returnArrayWithJokesFor:Ukraine];
    if (currentItem < [ukraineJokes count]) {
        NSDictionary *joke = [ukraineJokes objectAtIndex:currentItem];

        if ([[joke objectForKey:@"type"] isEqualToString:@"Multiply"]) {
            double multiply = [[joke objectForKey:@"amount"] doubleValue];
            self.grnToDollar.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"USD"] doubleValue] * multiply];
            self.grnToEuro.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"EUR"] doubleValue] * multiply];
            self.headLabel.text = [joke objectForKey:@"joke"];
            
        } else if ([[joke objectForKey:@"type"] isEqualToString:@"Divide"]) {
            double divide = [[joke objectForKey:@"amount"] doubleValue];
            self.grnToDollar.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"USD"] doubleValue] / divide];
            self.grnToEuro.text = [NSString stringWithFormat:@"%.2f", [[dataDict objectForKey:@"EUR"] doubleValue] / divide];
            self.headLabel.text = [joke objectForKey:@"joke"];
            
        } else {
            self.grnToDollar.text = [NSString stringWithFormat:@"%@", [joke objectForKey:@"amount"]];
            self.grnToEuro.text = [NSString stringWithFormat:@"%@", [joke objectForKey:@"amount"]];
            self.headLabel.text = [joke objectForKey:@"joke"];

        }
        
        if (!randomJoke) {
            currentItem += 1;
        } else {
            currentItem = arc4random_uniform(42);
        }
        
    } else {
        currentItem = 0;
        randomJoke = YES;
        [self healAction: sender];
    }
    
    
}

- (IBAction)homeButton:(GoodButton *)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
