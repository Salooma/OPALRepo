//
//  ThemeFactory.m
//  SleepyStoryboards
//
//  Created by Alexander Figueroa on 1/21/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "ThemeFactory.h"
#import "DefaultTheme.h"

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

- (id <Theme>)buildThemeForKey:(OPThemeSelectionOption)themeKey
{
    // Return Theme object based on on key
    switch (themeKey) {
            
        case OPThemeSelectionOptionDefaultTheme:
            return [[DefaultTheme alloc] init];
            break;
            
        default:
            return nil;
            break;
    }
}

- (id <Theme>)buildThemeForSettingsKey
{
    // Access userDefaults theme
    OPThemeSelectionOption themeSelection = (OPThemeSelectionOption)[[NSUserDefaults standardUserDefaults] integerForKey:OPThemeOption];
    
    return [self buildThemeForKey:themeSelection];
}

@end
