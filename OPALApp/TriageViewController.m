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

// Size of keyboard
@property (nonatomic) CGSize keyboardSize;

@end

@implementation TriageViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self applyTheme];
    [self registerForKeyBoardNotification];
    
    // Assign the delegate property for the UITextField
    self.pinTextField.delegate = (id <UITextFieldDelegate>)self;
}

#pragma mark - Theming Methods
- (void)applyTheme
{
    // Ask factory to build <Theme> compliant object to use as our themeSetter
    id <Theme> themeSetter = [[ThemeFactory sharedThemeFactory] buildThemeForSettingsKey];
    
    // Apply the themeSetters methods to apply to the view controller
    [themeSetter themeViewBackground:self.view];
    [themeSetter themeNavigationBar:self.navigationController.navigationBar];
    [themeSetter themeTabBar:self.tabBarController.tabBar];
}

#pragma mark - Notification Registering and De-registering

- (void) registerForKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:(self) selector:(@selector(keyboardWillShow:)) name:(UIKeyboardWillShowNotification) object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:(self) selector:(@selector(keyboardWillHide:)) name:(UIKeyboardWillHideNotification) object:nil];
}

- (void)deregisterForKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard Notification Methods
/*
 Thanks to StackOverflow: stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present
 */
- (void)keyboardWillShow:(NSNotification *)notification
{
    // Grab keyboard size
    NSDictionary *notificationInfo = [notification userInfo];
    self.keyboardSize = [[notificationInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Animate the current view out of the way
    if (CGRectGetMinY(self.view.frame) >= 0)
        [self setViewMovedUp:YES];
    else if (CGRectGetMinY(self.view.frame) < 0)
        [self setViewMovedUp:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (CGRectGetMinY(self.view.frame) >= 0)
        [self setViewMovedUp:YES];
    else if (CGRectGetMinY(self.view.frame) < 0)
        [self setViewMovedUp:NO];
}

- (void)setViewMovedUp:(BOOL)movedUp
{
    // Move the view up an down whenever keyboard is shown/dismissed
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect viewFrame = self.view.frame;
    
    if (movedUp)
    {
        // Shift everything up by the height of the keyboard
        viewFrame.origin.y -= self.keyboardSize.height;
        viewFrame.size.height += self.keyboardSize.height;
    } else {
        // Revert back to normal state
    }
    
    self.view.frame = viewFrame;
    
    [UIView commitAnimations];
}

- (void)adjustForKeyboardOffset:(UIView *)view
{

}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.pinTextField])
    {
        // Move the main view so keyboard does not hide it
        if (CGRectGetMinY(self.view.frame) >= 0)
            [self setViewMovedUp:YES];
    }
}

#pragma mark - Cleanup
- (void) dealloc
{
    [self deregisterForKeyBoardNotification];
}


@end
