//
//  BlueBeigeTheme.m
//  SleepCycleSeven
//
//  Created by Alexander Figueroa on 12/23/2013.
//  Copyright (c) 2013 Alexander Figueroa. All rights reserved.
//

#import "BlueBeigeTheme.h"
#import "UIColor+Colours.h"

@implementation BlueBeigeTheme

- (instancetype)init
{
    // Init with base class implementations
    self = [super initWithBackgroundColor:[UIColor blueberryColor]
                 secondaryBackgroundColor:[UIColor eggshellColor]
        alternateSecondaryBackgroundColor:[UIColor blueberryColor]
                                textColor:[UIColor whiteColor]
                       secondaryTextColor:[UIColor blackColor]];

    // Assign themeEnum to allow for ImageViewManagerFactory to handle images properly
    self.themeEnum = AFThemeSelectionOptionBlueBeigeTheme;
    
    return self;
}

@end
