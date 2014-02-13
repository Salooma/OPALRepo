//
//  TriageViewController.h
//  OPALApp
//
//  Created by Alexander Figueroa on 1/23/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PasswordHandler;

@interface TriageViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id <PasswordHandler> passwordHandler;
@property (assign) BOOL isCurrentlyOnScreen;

@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) UIColor *navigationTintColor;
@property (nonatomic, strong) UIColor *navigationTitleColor;

@end

@protocol PasswordHandler <NSObject>

@required
- (BOOL)triageViewController:(TriageViewController *)triageViewController verifyPassword:(NSString *)password;

@optional
// This serves, mostly, as an "update stuff after dismissing"
- (void)maxNumberOfFailedAttemptsReached;
- (void)passcodeWasEnteredSuccessfully;
- (void)passcodeViewControllerWasDismissed;

@end
