//
//  DefaultTheme.m
//  OPALApp
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "DefaultTheme.h"
#import "UIColor+FlatUI.h"

@implementation DefaultTheme

- (instancetype)init
{
    // Init with base class implementations
    self = [super initWithBackgroundColor:[UIColor oslerSalmonColor]
                 secondaryBackgroundColor:[UIColor whiteColor]
        alternateSecondaryBackgroundColor:[UIColor oslerSalmonColor]
                                textColor:[UIColor whiteColor]
                       secondaryTextColor:[UIColor blackColor]];
    
    // Assign themeEnum to allow for ImageViewManagerFactory to handle images properly
    self.themeEnum = OPThemeSelectionOptionDefaultTheme;
    
    return self;
}


@end
