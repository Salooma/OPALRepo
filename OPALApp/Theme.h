//
//  Theme.h
//  SleepCycleSeven
//
//  Created by Alexander Figueroa on 12/23/2013.
//  Copyright (c) 2013 Alexander Figueroa. All rights reserved.
//
//  Define the protocol which every theme must adhere to

#import <Foundation/Foundation.h>

@protocol Theme <NSObject>

@required

// Themes the background color of the view in primary fashion
- (void)themeViewBackground:(UIView *)view;

// Themes the background view in the alternate fashion
- (void)alternateThemeViewBackground:(UIView *)view;

// Theme the UINavigationBar
- (void)themeNavigationBar:(UINavigationBar *)navBar;

// Theme the UIButton's in primary or alternate fashion
- (void)themeButton:(UIButton *)button withFont:(UIFont *)font;
- (void)alternateThemeButton:(UIButton *)button withFont:(UIFont *)font;

// Theme the UILabel's in primary or alternate fashion
- (void)themeLabel:(UILabel *)label withFont:(UIFont *)font;
- (void)alternateThemeLabel:(UILabel *)label withFont:(UIFont *)font;

// Theme the refresh control
- (void)themeRefreshControl:(UIRefreshControl *)refreshControl;

// Theme the UITableView and its corresponding UITableViewCells in
// ascending/descending brightness pattern
- (void)themeTableView:(UITableView *)tableView;

// Theme the UISwitch
- (void)themeSwitch:(UISwitch *)switchControl;

// Theme the UISlider
- (void)themeSlider:(UISlider *)slider;

// Theme the UITextField
- (void)themeTextField:(UITextField *)textField;

// Theme the border used for a given view
- (void)themeBorderForView:(UIView *)view visible:(BOOL)isVisible;

// Theme the Tab bar the same as the navigation bar
- (void)themeTabBar:(UITabBar *)tabBar;

@end
