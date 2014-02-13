//
//  BaseTheme.m
//  SleepyStoryboards
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "BaseTheme.h"
#import "UINavigationBar+FlatUI.h"
#import "FUIButton.h"
#import "UITabBar+FlatUI.h"

@interface BaseTheme ()

@end

@implementation BaseTheme 

- (instancetype)initWithBackgroundColor:(UIColor *)backgroundColor
               secondaryBackgroundColor:(UIColor *)secondaryBackgroundColor
      alternateSecondaryBackgroundColor:(UIColor *)altSecondaryBackgroundColor
                              textColor:(UIColor *)textColor
                     secondaryTextColor:(UIColor *)secondaryTextColor
{
    self = [super init];
    
    if (self)
    {
        // Set the appropriate colors to be used within theming
        self.primaryBackgroundColor = backgroundColor;
        self.secondaryBackgroundColor = secondaryBackgroundColor;
        self.alternateSecondaryBackgroundColor = altSecondaryBackgroundColor;
        self.primaryTextColor = textColor;
        self.secondaryTextColor = secondaryTextColor;
        
    }

    return self;
}

#pragma mark - Theme Protocol
- (void)themeViewBackground:(UIView *)view
{
    // Configure the background color with primary background color
    view.backgroundColor = self.secondaryBackgroundColor;
}

- (void)alternateThemeViewBackground:(UIView *)view
{
    // Configure view with alternate background cover
    view.backgroundColor = self.primaryBackgroundColor;
}

- (void)themeNavigationBar:(UINavigationBar *)navBar
{
    // Theme the navigation color to have whiteColor text.
    navBar.tintColor = [UIColor whiteColor];
    navBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Futura" size:21.0f],
                                   NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Adjust the status bar for whiteColor text
    // NOTE this will only work if "View controller-based status bar appearance" is set to NO
    // in Target > Info > Custom iOS Target Properties
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Configure the navigation bars background color
    [navBar configureFlatNavigationBarWithColor:self.primaryBackgroundColor];
}

- (void)themeButton:(UIButton *)button withFont:(UIFont *)font
{
    button.backgroundColor = self.primaryBackgroundColor;
    
    button.titleLabel.font = font;
    [button setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [button setTitleColor:self.primaryTextColor forState:UIControlStateHighlighted];
}

- (void)alternateThemeButton:(UIButton *)button withFont:(UIFont *)font
{
    FUIButton *flatButton = (FUIButton *)button;
    
    flatButton.buttonColor = [UIColor clearColor];
    flatButton.shadowColor = [UIColor clearColor];
    flatButton.shadowHeight = 0.0f;
    flatButton.cornerRadius = 3.0f;
    
    flatButton.titleLabel.font = font;
    [flatButton setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [flatButton setTitleColor:self.primaryTextColor forState:UIControlStateHighlighted];
}

- (void)themeLabel:(UILabel *)label withFont:(UIFont *)font
{
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.primaryTextColor;
    label.backgroundColor = [UIColor clearColor];
}

- (void)alternateThemeLabel:(UILabel *)label withFont:(UIFont *)font
{
    [self themeLabel:label withFont:font];
    label.textColor = self.primaryBackgroundColor;
}

- (void)themeRefreshControl:(UIRefreshControl *)refreshControl
{
    refreshControl.backgroundColor = self.primaryBackgroundColor;
}

- (void)themeTableView:(UITableView *)tableView
{
    tableView.backgroundColor = self.primaryBackgroundColor;
    tableView.separatorColor = self.secondaryBackgroundColor;
}

- (void)themeSwitch:(UISwitch *)switchControl
{
    switchControl.onTintColor = self.primaryBackgroundColor;
}

- (void)themeSlider:(UISlider *)slider
{
    slider.tintColor = self.primaryBackgroundColor;
}

- (void)themeTextField:(UITextField *)textField
{
    textField.textColor = self.secondaryTextColor;
}

- (void)themeBorderForView:(UIView *)view visible:(BOOL)isVisible
{
    CGColorRef borderColor;
    
    if (isVisible)
        borderColor = [[UIColor blackColor] CGColor];
    else
        borderColor = [[UIColor clearColor] CGColor];
    
    view.layer.borderColor = borderColor;
    view.layer.borderWidth = 1.5f;
}

- (void)themeTabBar:(UITabBar *)tabBar
{
    [tabBar configureFlatTabBarWithColor:self.primaryBackgroundColor];
}

@end
