//
//  BackgroundView.m
//  CheTamUHohlov
//
//  Created by Admin on 27.02.16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void)drawRect:(CGRect)rect {
    
    CGFloat wS = self.frame.size.width / 24;
    CGFloat hS = self.frame.size.height / 40;
    UIColor *color = [UIColor colorWithRed:0.819608 green:0.211765 blue:0.192157 alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, hS * 27);
    CGContextAddLineToPoint(context, wS, hS * 22);
    CGContextAddLineToPoint(context, wS * 3, hS * 26);
    CGContextAddLineToPoint(context, wS * 4, hS * 19);
    CGContextAddLineToPoint(context, wS * 5, hS * 23);
    CGContextAddLineToPoint(context, wS * 8, hS * 20);
    CGContextAddLineToPoint(context, wS * 9, hS * 22);
    CGContextAddLineToPoint(context, wS * 12, hS * 23);
    CGContextAddLineToPoint(context, wS * 14, hS * 20);
    CGContextAddLineToPoint(context, wS * 15, hS * 22);
    CGContextAddLineToPoint(context, wS * 19, hS * 18);
    CGContextAddLineToPoint(context, wS * 19, hS * 23);
    CGContextAddLineToPoint(context, wS * 20, hS * 26);
    CGContextAddLineToPoint(context, wS * 21, hS * 23);
    CGContextAddLineToPoint(context, wS * 23, hS * 28);
    CGContextAddLineToPoint(context, self.frame.size.width, hS * 20);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    
    CGContextFillPath(context);
    
    self.healButton = CGRectMake(15, (29 * hS + 8),
                                 (self.frame.size.width - 30), ((self.frame.size.height - (hS * 29) - 50 - (8 * 3)) / 2));
    self.homeButton = CGRectMake(15, (self.frame.size.height - 55 - ((self.frame.size.height - (hS * 29) - 50 - (8 * 3)) / 2)),
                                 (self.frame.size.width - 30), ((self.frame.size.height - (hS * 29) - 50 - (8 * 3)) / 2));
    
    self.productPrice = CGRectMake((wS * 5), (hS * 23), (wS * 14), ((hS * 6) / 3 * 2));
    self.productLabel = CGRectMake((wS * 5), ((hS * 29) - ((hS * 6) / 3) - 10), (wS * 14), ((hS * 6) / 3));
    
    self.headerLabel = CGRectMake(wS, (hS * 2), (self.frame.size.width - (wS * 2)), (hS * 4));
    
    self.usdPrice = CGRectMake((wS * 5), (hS * 7), self.productPrice.size.width, self.productPrice.size.height);
    self.usdLabel = CGRectMake((wS * 5), ((hS * 7) + self.productPrice.size.height - 10), self.productLabel.size.width, self.productLabel.size.height);
    
    self.eurPrice = CGRectMake((wS * 5), (hS * 13), self.productPrice.size.width, self.productPrice.size.height);
    self.eurLabel = CGRectMake((wS * 5), ((hS * 13) + self.productPrice.size.height - 10), self.productLabel.size.width, self.productLabel.size.height);
    
}


@end
