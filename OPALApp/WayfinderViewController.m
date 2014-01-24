//
//  WayfinderViewController.m
//  OPALApp
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "WayfinderViewController.h"
#import "BaseTheme.h"
#import "ThemeFactory.h"

@interface WayfinderViewController ()

@end

@implementation WayfinderViewController

- (void)awakeFromNib
{
    // This method is called when the storyboard file is loaded into memory
    [super awakeFromNib];
    
    // Call the applyTheme on initialization of view
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
