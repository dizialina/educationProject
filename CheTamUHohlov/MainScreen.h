//
//  ViewController.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/4/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheTamUHohlov-Swift.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MainScreen : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UILabel *grnToDollar;
@property (weak, nonatomic) IBOutlet UILabel *grnToEuro;
@property (weak, nonatomic) IBOutlet UILabel *saloPrice;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

- (IBAction)healAction:(GoodButton *)sender;
- (IBAction)homeButton:(GoodButton *)sender;


@end

