//
//  TriageViewController.m
//  OPALApp
//
//  Created by Alexander Figueroa on 1/23/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "TriageViewController.h"
#import "BaseTheme.h"
#import "ThemeFactory.h"

@interface TriageViewController ()

@end

@implementation TriageViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self applyTheme];
}

- (void)applyTheme
{
    // Ask factory to build <Theme> compliant object to use as our themeSetter
    id <Theme> themeSetter = [[ThemeFactory sharedThemeFactory] buildThemeForSettingsKey];
    
    // Apply the themeSetters methods to apply to the view controller
    [themeSetter themeViewBackground:self.view];
    [themeSetter themeNavigationBar:self.navigationController.navigationBar];
    [themeSetter themeTabBar:self.tabBarController.tabBar];
}

@end
