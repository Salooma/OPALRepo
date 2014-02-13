//
//  PasswordHandling.h
//  OPALApp
//
//  Created by Alexander Figueroa on 2/13/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TriageViewController;

/**
 @brief The PasswordHandler protocol defines methods for which an object can receive that indicate the actions of the
 password input in order to verify.
 */
@protocol PasswordHandling <NSObject>

@required
- (BOOL)triageViewController:(TriageViewController *)triageViewController verifyPassword:(NSString *)password;

@optional
// This serves, mostly, as an "update stuff after dismissing"
- (void)maxNumberOfFailedAttemptsReached;

@end
