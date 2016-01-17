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
#import "HomeScreen.h"
#import "CheTamUHohlov-Swift.h"
@interface ViewController ()

@property (strong, nonatomic) TestCurRateObj *curRateObj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateDataInView];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDataInView) name:NotificationAboutLoadingData object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    self.homeButton.titleLabel.text = NSLocalizedString(@"HomeButton", @"Home button in home screen"); 
}
    


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDataInView {
    
    ObjClient *objClient = [ObjClient new];
    NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate WHERE Name=\'%@\'", @"USD/RUB"];
    NSArray *testResultArray = [objClient testReturnCurrencyRateObjectArray:testSelectQueue];
    NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
    if (testResultArray.count != 0) {
        self.curRateObj = [testResultArray firstObject];
        
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *selectQueue = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"RUB"];
        NSArray *resultArray = [objClient returnCurrencyRateObjectArray:selectQueue];
        NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArray count]);
        if (resultArray.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                BankRateItem *bankRateItem = [resultArray firstObject];
                self.currencyNameLabel.text = bankRateItem.shortCurName;
                self.rateLabel.text = [NSString stringWithFormat:@"%.3f", bankRateItem.rate];
            });
        }
        
        
    });
    
    UIImage *image = [UIImage imageNamed:@"ArrowButton"];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toHome"]) {
        HomeScreen *homeScreen = segue.destinationViewController;
        homeScreen.curRateObj = self.curRateObj;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
