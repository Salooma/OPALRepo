//
//  DefaultTheme.m
//  OPALApp
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "DefaultTheme.h"

@implementation DefaultTheme

- (instancetype)init
{
    // Init with base class implementations
    self = [super initWithBackgroundColor:[UIColor blueberryColor]
                 secondaryBackgroundColor:[UIColor eggshellColor]
        alternateSecondaryBackgroundColor:[UIColor blueberryColor]
                                textColor:[UIColor whiteColor]
                       secondaryTextColor:[UIColor blackColor]];
    
    // Assign themeEnum to allow for ImageViewManagerFactory to handle images properly
    self.themeEnum = OPThemeSelectionOptionDefaultTheme;
    
    return self;
}


@end
