//
//  ThemeFactory.h
//  SleepyStoryboards
//
//  Created by Alexander Figueroa on 1/21/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

// The ThemeFactory to provide themes to our view controller objects

#import <Foundation/Foundation.h>
#import "Theme.h"

@interface ThemeFactory : NSObject

+ (instancetype)sharedThemeFactory;

- (id <Theme>)buildThemeForKey:(AFThemeSelectionOption)themeKey;
- (id <Theme>)buildThemeForSettingsKey;

@end
