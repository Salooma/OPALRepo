//
//  BaseTheme.h
//  SleepyStoryboards
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Theme.h"

@interface BaseTheme : NSObject <Theme>

// Primary color is usually the UINavigationBar background color
@property (nonatomic, strong) UIColor *primaryBackgroundColor;

// Secondary color is the actual view background color and alternate can be used for dark themes
@property (nonatomic, strong) UIColor *secondaryBackgroundColor;
@property (nonatomic, strong) UIColor *alternateSecondaryBackgroundColor;

// The text colors to be used to contrast with the background colors
@property (nonatomic, strong) UIColor *primaryTextColor;
@property (nonatomic, strong) UIColor *secondaryTextColor;

// The enum to be used for any factory methods
@property (assign) NSInteger themeEnum;


- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
               secondaryBackgroundColor:(UIColor *)secondaryBackgroundColor
      alternateSecondaryBackgroundColor:(UIColor *)altSecondaryBackgroundColor
                              textColor:(UIColor *)textColor
                     secondaryTextColor:(UIColor *)secondaryTextColor;

@end
