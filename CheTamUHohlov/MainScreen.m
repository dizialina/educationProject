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

@interface MainScreen ()

@property (strong, nonatomic) NSArray *curRateObj;

@end

@implementation MainScreen

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataInView)
                                                 name:NotificationAboutLoadingGovData
                                               object:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.homeButton.titleLabel.text = NSLocalizedString(@"HomeButton", @"Home button in home screen"); 
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDataInView {
    
    ObjClient *objClient = [ObjClient new];
    //NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate WHERE Name=\'%@\'", @"USD/RUB"];
    NSString *testSelectQueue = [NSString stringWithFormat:@"SELECT * FROM yahooCurrencyRate"];
    NSArray *testResultArray = [objClient returnCurrencyRateObjectArrayFromYahooBD:testSelectQueue];
    NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[testResultArray count]);
    if (testResultArray.count != 0) {
        self.curRateObj = testResultArray;
        
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *selectQueue = [NSString stringWithFormat:@"SELECT * FROM CurrencyRate WHERE ShortCurName=\'%@\'", @"RUB"];
        NSArray *resultArray = [objClient returnCurrencyRateObjectArrayFromGovDB:selectQueue];
        NSLog(@"Count of items in result array after SELECT queue: %lu", (unsigned long)[resultArray count]);
        if (resultArray.count != 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                RateItemFromGov *bankRateItem = [resultArray firstObject];
                self.currencyNameLabel.text = bankRateItem.shortCurName;
                self.rateLabel.text = [NSString stringWithFormat:@"%.3f", bankRateItem.rate];
            });
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)soundButtonAction:(id)sender {
    
    UIImage *imageSoundOff = [UIImage imageNamed:@"SoundOff"];
    UIImage *imageSoundOn = [UIImage imageNamed:@"SoundOn"];
    
    if ([self.backgroundMusic isPlaying]) {
        [self.soundButton setImage:imageSoundOff forState:UIControlStateNormal];
        [self.backgroundMusic pause];
    } else {
        [self.soundButton setImage:imageSoundOn forState:UIControlStateNormal];
        [self.backgroundMusic play];
    }
    
}

@end
