//
//  ViewController.m
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "ViewController.h"
#import "ObjClient.h"
#import "BankRateItem.h"
#import "TestCurRateObj.h" //тест(удалить)
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateDataInView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataInView) name:NotificationAboutLoadingData object:nil];
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDataInView {
    
    //    NSString *selectQueue = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"RUB"];
    //    NSArray *resultArray = [objClient returnCurrencyRateObjectArray:selectQueue];
    //    NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArray count]);
    //    if (resultArray.count != 0) {
    //        BankRateItem *bankRateItem = [resultArray firstObject];
    //        self.currencyNameLabel.text = bankRateItem.shortCurName;
    //        self.rateLabel.text = [NSString stringWithFormat:@"%.3f", bankRateItem.rate];
    //        
    //    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        ObjClient *objClient = [ObjClient new];
        NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate WHERE Name=\'%@\'", @"USD/RUB"];
        NSArray *testResultArray = [objClient testReturnCurrencyRateObjectArray:testSelectQueue];
        NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
        if (testResultArray.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
            TestCurRateObj *bankRateItem = [testResultArray firstObject];
            self.currencyNameLabel.text = bankRateItem.pairCurName;
            self.rateLabel.text = [NSString stringWithFormat:@"%.3f", bankRateItem.rate];
            });
        }
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
