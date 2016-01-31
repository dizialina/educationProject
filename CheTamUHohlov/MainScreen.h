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


@property (weak, nonatomic) IBOutlet GoodButton *homeButton;
@property (weak, nonatomic) IBOutlet UILabel *currencyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

- (IBAction)soundButtonAction:(id)sender;


@end

