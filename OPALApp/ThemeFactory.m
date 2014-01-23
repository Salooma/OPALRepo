//
//  ThemeFactory.m
//  SleepyStoryboards
//
//  Created by Alexander Figueroa on 1/21/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "ThemeFactory.h"
#import "SettingsManager.h"
#import "BlueBeigeTheme.h"
#import "BlackGrayTheme.h"
#import "RedRoseTheme.h"

@implementation ThemeFactory

+ (instancetype)sharedThemeFactory
{
    static ThemeFactory *sharedThemeFactory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeFactory = [[ThemeFactory alloc] init];
    });
    
    return sharedThemeFactory;
}

- (id <Theme>)buildThemeForKey:(AFThemeSelectionOption)themeKey
{
    // Return Theme object based on on key
    switch (themeKey) {
            
        case AFThemeSelectionOptionBlueBeigeTheme:
            return [[BlueBeigeTheme alloc] init];
            break;
            
        case AFThemeSelectionOptionBlackGrayTheme:
            return [[BlackGrayTheme alloc] init];
            break;
            
        case AFThemeSelectionOptionRedRoseTheme:
            return [[RedRoseTheme alloc] init];
            break;
            
        default:
            return nil;
            break;
    }
}

- (id <Theme>)buildThemeForSettingsKey
{
    // Access userDefaults theme
    AFThemeSelectionOption themeSelection = (AFThemeSelectionOption)[[SettingsManager sharedSettings] appTheme];
    
    return [self buildThemeForKey:themeSelection];
}

@end
