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
#import "SFHFKeychainUtils.h"
#import "PasswordHandler.h"

@interface TriageViewController ()
@property(nonatomic, strong) UIView *currentView;
@property(nonatomic,assign) BOOL isPasswordSuccessful;

@end

static NSString *const kKeychainPasscode = @"demoPasscode";
static NSString *const kKeychainTimerStart = @"demoPasscodeTimerStart";
static NSString *const kKeychainServiceName = @"demoServiceName";
static NSString *const kUserDefaultsKeyForTimerDuration = @"passcodeTimerDuration";
static NSString *const kPasscodeCharacter = @"\u2014"; // A longer "-"
static CGFloat const kLabelFontSize = 15.0f;
static CGFloat const kPasscodeFontSize = 33.0f;
static CGFloat const kFontSizeModifier = 1.5f;
static CGFloat const kiPhoneHorizontalGap = 40.0f;
static CGFloat const kLockAnimationDuration = 0.15f;
static CGFloat const kSlideAnimationDuration = 0.15f;
// Set to 0 if you want to skip the check. If you don't, nothing happens,
// just maxNumberOfAllowedFailedAttempts protocol method is checked for and called.
static NSInteger const kMaxNumberOfAllowedFailedAttempts = 10;

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
// Gaps
// To have a properly centered Passcode, the horizontal gap difference between iPhone and iPad
// must have the same ratio as the font size difference between them.
#define kHorizontalGap (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kiPhoneHorizontalGap * kFontSizeModifier : kiPhoneHorizontalGap)
#define kVerticalGap (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60.0f : 25.0f)
#define kModifierForBottomVerticalGap (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.6f : 3.0f)
// Text Sizes
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define kPasscodeCharWidth [kPasscodeCharacter sizeWithAttributes: @{NSFontAttributeName : kPasscodeFont}].width
#define kFailedAttemptLabelWidth (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width + 60.0f : [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width + 30.0f)
#define kFailedAttemptLabelHeight [_failedAttemptLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].height
#define kEnterPasscodeLabelWidth [_enterPasscodeLabel.text sizeWithAttributes: @{NSFontAttributeName : kLabelFont}].width
#else
// Thanks to Kent Nguyen - https://github.com/kentnguyen
#define kPasscodeCharWidth [kPasscodeCharacter sizeWithFont:kPasscodeFont].width
#define kFailedAttemptLabelWidth (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedAttemptLabel.text sizeWithFont:kLabelFont].width + 60.0f : [_failedAttemptLabel.text sizeWithFont:kLabelFont].width + 30.0f)
#define kFailedAttemptLabelHeight [_failedAttemptLabel.text sizeWithFont:kLabelFont].height
#define kEnterPasscodeLabelWidth [_enterPasscodeLabel.text sizeWithFont:kLabelFont].width
#endif
// Backgrounds
#define kEnterPasscodeLabelBackgroundColor [UIColor clearColor]
#define kBackgroundColor [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f]
#define kCoverViewBackgroundColor [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f]
#define kPasscodeBackgroundColor [UIColor clearColor]
#define kFailedAttemptLabelBackgroundColor [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f]
// Fonts
#define kLabelFont (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize * kFontSizeModifier] : [UIFont fontWithName: @"AvenirNext-Regular" size: kLabelFontSize])
#define kPasscodeFont (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [UIFont fontWithName: @"AvenirNext-Regular" size: kPasscodeFontSize * kFontSizeModifier] : [UIFont fontWithName: @"AvenirNext-Regular" size: kPasscodeFontSize])
// Text Colors
#define kLabelTextColor [UIColor colorWithWhite:0.31f alpha:1.0f]
#define kPasscodeTextColor [UIColor colorWithWhite:0.31f alpha:1.0f]
#define kFailedAttemptLabelTextColor [UIColor whiteColor]

@implementation TriageViewController
{
    UIView *_animatingView;
    UITextField *_firstDigitTextField;
    UITextField *_secondDigitTextField;
    UITextField *_thirdDigitTextField;
    UITextField *_fourthDigitTextField;
    UITextField *_passcodeTextField;
    UILabel *_failedAttemptLabel;
    UILabel *_enterPasscodeLabel;
    int _failedAttempts;
    BOOL _isUserConfirmingPasscode;
    BOOL _isUserBeingAskedForNewPasscode;
    BOOL _isUserTurningPasscodeOff;
    BOOL _isUserChangingPasscode;
    BOOL _isUserEnablingPasscode;
    BOOL _beingDisplayedAsLockScreen;
    NSString *_tempPasscode;
    BOOL _timerStartInSeconds;
}

- (UIView *) currentView
{
    if(self.isPasswordSuccessful)
        return [self mainView];
    else
        return [self passwordView];
}

- (UIView *) mainView
{
    UIView *mainView = [[UIView alloc] init];
    mainView.frame=[UIScreen mainScreen].bounds;

    mainView.backgroundColor = kBackgroundColor;
    
    UILabel *label = [[UILabel alloc] init];
    label.text=@"QUEUE VIEW";
    label.frame = CGRectMake(mainView.center.x, mainView.center.y, 150, 50);
    
    [mainView addSubview:label];
    
    return mainView;
    
}

- (UIView *) passwordView
{
    UIView *passwordView = [[UIView alloc] init];
    passwordView.frame=[UIScreen mainScreen].bounds;
    
    passwordView.backgroundColor = kBackgroundColor;
    
    _failedAttempts = 0;
	_animatingView = [[UIView alloc] initWithFrame: self.view.frame];
	[passwordView addSubview: _animatingView];
	
	_enterPasscodeLabel = [[UILabel alloc] initWithFrame: CGRectZero];
	_enterPasscodeLabel.backgroundColor = kEnterPasscodeLabelBackgroundColor;
	_enterPasscodeLabel.textColor = kLabelTextColor;
	_enterPasscodeLabel.font = kLabelFont;
	_enterPasscodeLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview: _enterPasscodeLabel];
	
	// It is also used to display the "Passcodes did not match" error message if the user fails to confirm the passcode.
	_failedAttemptLabel = [[UILabel alloc] initWithFrame: CGRectZero];
	_failedAttemptLabel.text = @"1 Passcode Failed Attempt";
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttemptLabel.font = kLabelFont;
	_failedAttemptLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview: _failedAttemptLabel];
	
	_firstDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _firstDigitTextField.backgroundColor = kPasscodeBackgroundColor;
    _firstDigitTextField.textAlignment = NSTextAlignmentCenter;
	_firstDigitTextField.text = kPasscodeCharacter;
	_firstDigitTextField.textColor = kPasscodeTextColor;
	_firstDigitTextField.font = kPasscodeFont;
	_firstDigitTextField.secureTextEntry = NO;
    [_firstDigitTextField setBorderStyle:UITextBorderStyleNone];
	_firstDigitTextField.userInteractionEnabled = NO;
    [_animatingView addSubview:_firstDigitTextField];
	
	_secondDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _secondDigitTextField.backgroundColor = kPasscodeBackgroundColor;
    _secondDigitTextField.textAlignment = NSTextAlignmentCenter;
	_secondDigitTextField.text = kPasscodeCharacter;
	_secondDigitTextField.textColor = kPasscodeTextColor;
	_secondDigitTextField.font = kPasscodeFont;
	_secondDigitTextField.secureTextEntry = NO;
    [_secondDigitTextField setBorderStyle:UITextBorderStyleNone];
	_secondDigitTextField.userInteractionEnabled = NO;
    [_animatingView addSubview:_secondDigitTextField];
	
	_thirdDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _thirdDigitTextField.backgroundColor = kPasscodeBackgroundColor;
    _thirdDigitTextField.textAlignment = NSTextAlignmentCenter;
	_thirdDigitTextField.text = kPasscodeCharacter;
	_thirdDigitTextField.textColor = kPasscodeTextColor;
	_thirdDigitTextField.font = kPasscodeFont;
	_thirdDigitTextField.secureTextEntry = NO;
    [_thirdDigitTextField setBorderStyle:UITextBorderStyleNone];
	_thirdDigitTextField.userInteractionEnabled = NO;
    [_animatingView addSubview:_thirdDigitTextField];
	
	_fourthDigitTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _fourthDigitTextField.backgroundColor = kPasscodeBackgroundColor;
    _fourthDigitTextField.textAlignment = NSTextAlignmentCenter;
	_fourthDigitTextField.text = kPasscodeCharacter;
	_fourthDigitTextField.textColor = kPasscodeTextColor;
	_fourthDigitTextField.font = kPasscodeFont;
	_fourthDigitTextField.secureTextEntry = NO;
    [_fourthDigitTextField setBorderStyle:UITextBorderStyleNone];
	_fourthDigitTextField.userInteractionEnabled = NO;
    [_animatingView addSubview:_fourthDigitTextField];
	
	_passcodeTextField = [[UITextField alloc] initWithFrame: CGRectZero];
	_passcodeTextField.hidden = YES;
	_passcodeTextField.delegate = self;
	_passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	[_passcodeTextField becomeFirstResponder];
    [_animatingView addSubview:_passcodeTextField];
	
	_enterPasscodeLabel.text = _isUserChangingPasscode ? NSLocalizedString(@"Enter your old passcode", @"") : NSLocalizedString(@"Enter your passcode", @"");
	
	_enterPasscodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_failedAttemptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _firstDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_secondDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_thirdDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_fourthDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraintsForView:(passwordView)];
    
    // Create Cancel UIBarButtonItem
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismissMe)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    return passwordView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.passwordHandler)
        self.passwordHandler = [[PasswordHandler alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view=self.currentView;
	
}

- (void) addConstraintsForView : (UIView *)view
{
    // MARK: Please read
	// The controller works properly on all devices and orientations, but looks odd on iPhone's landscape.
	// Usually, lockscreens on iPhone are kept portrait-only, though. It also doesn't fit inside a modal when landscape.
	// That's why only portrait is selected for iPhone's supported orientations.
	// Modify this to fit your needs.
	
	CGFloat yOffsetFromCenter = -view.frame.size.height * 0.24;
	NSLayoutConstraint *enterPasscodeConstraintCenterX = [NSLayoutConstraint constraintWithItem: _enterPasscodeLabel
																					  attribute: NSLayoutAttributeCenterX
																					  relatedBy: NSLayoutRelationEqual
																						 toItem: view
																					  attribute: NSLayoutAttributeCenterX
																					 multiplier: 1.0f
																					   constant: 0.0f];
	NSLayoutConstraint *enterPasscodeConstraintCenterY = [NSLayoutConstraint constraintWithItem: _enterPasscodeLabel
																					  attribute: NSLayoutAttributeCenterY
																					  relatedBy: NSLayoutRelationEqual
																						 toItem: view
																					  attribute: NSLayoutAttributeCenterY
																					 multiplier: 1.0f
																					   constant: yOffsetFromCenter];
    [view addConstraint: enterPasscodeConstraintCenterX];
    [view addConstraint: enterPasscodeConstraintCenterY];
	
	NSLayoutConstraint *firstDigitX = [NSLayoutConstraint constraintWithItem: _firstDigitTextField
																   attribute: NSLayoutAttributeLeft
																   relatedBy: NSLayoutRelationEqual
																	  toItem: view
																   attribute: NSLayoutAttributeCenterX
																  multiplier: 1.0f
																	constant: - kHorizontalGap * 1.5f - 2.0f];
	NSLayoutConstraint *secondDigitX = [NSLayoutConstraint constraintWithItem: _secondDigitTextField
																	attribute: NSLayoutAttributeLeft
																	relatedBy: NSLayoutRelationEqual
																	   toItem: view
																	attribute: NSLayoutAttributeCenterX
																   multiplier: 1.0f
																	 constant: - kHorizontalGap * 2/3 - 2.0f];
	NSLayoutConstraint *thirdDigitX = [NSLayoutConstraint constraintWithItem: _thirdDigitTextField
																   attribute: NSLayoutAttributeLeft
																   relatedBy: NSLayoutRelationEqual
																	  toItem: view
																   attribute: NSLayoutAttributeCenterX
																  multiplier: 1.0f
																	constant: kHorizontalGap * 1/6 - 2.0f];
	NSLayoutConstraint *fourthDigitX = [NSLayoutConstraint constraintWithItem: _fourthDigitTextField
																	attribute: NSLayoutAttributeLeft
																	relatedBy: NSLayoutRelationEqual
																	   toItem: view
																	attribute: NSLayoutAttributeCenterX
																   multiplier: 1.0f
																	 constant: kHorizontalGap - 2.0f];
	NSLayoutConstraint *firstDigitY = [NSLayoutConstraint constraintWithItem: _firstDigitTextField
																   attribute: NSLayoutAttributeCenterY
																   relatedBy: NSLayoutRelationEqual
																	  toItem: _enterPasscodeLabel
																   attribute: NSLayoutAttributeBottom
																  multiplier: 1.0f
																	constant: kVerticalGap];
	NSLayoutConstraint *secondDigitY = [NSLayoutConstraint constraintWithItem: _secondDigitTextField
																	attribute: NSLayoutAttributeCenterY
																	relatedBy: NSLayoutRelationEqual
																	   toItem: _enterPasscodeLabel
																	attribute: NSLayoutAttributeBottom
																   multiplier: 1.0f
																	 constant: kVerticalGap];
	NSLayoutConstraint *thirdDigitY = [NSLayoutConstraint constraintWithItem: _thirdDigitTextField
																   attribute: NSLayoutAttributeCenterY
																   relatedBy: NSLayoutRelationEqual
																	  toItem: _enterPasscodeLabel
																   attribute: NSLayoutAttributeBottom
																  multiplier: 1.0f
																	constant: kVerticalGap];
	NSLayoutConstraint *fourthDigitY = [NSLayoutConstraint constraintWithItem: _fourthDigitTextField
																	attribute: NSLayoutAttributeCenterY
																	relatedBy: NSLayoutRelationEqual
																	   toItem: _enterPasscodeLabel
																	attribute: NSLayoutAttributeBottom
																   multiplier: 1.0f
																	 constant: kVerticalGap];
	[view addConstraint:firstDigitX];
	[view addConstraint:secondDigitX];
	[view addConstraint:thirdDigitX];
	[view addConstraint:fourthDigitX];
	[view addConstraint:firstDigitY];
	[view addConstraint:secondDigitY];
	[view addConstraint:thirdDigitY];
	[view addConstraint:fourthDigitY];
	
    NSLayoutConstraint *failedAttemptLabelCenterX = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				 attribute: NSLayoutAttributeCenterX
																				 relatedBy: NSLayoutRelationEqual
																					toItem: view
																				 attribute: NSLayoutAttributeCenterX
																				multiplier: 1.0f
																				  constant: 0.0f];
	NSLayoutConstraint *failedAttemptLabelCenterY = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				 attribute: NSLayoutAttributeCenterY
																				 relatedBy: NSLayoutRelationEqual
																					toItem: _enterPasscodeLabel
																				 attribute: NSLayoutAttributeBottom
																				multiplier: 1.0f
																				  constant: kVerticalGap * kModifierForBottomVerticalGap - 2.0f];
	NSLayoutConstraint *failedAttemptLabelWidth = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																			   attribute: NSLayoutAttributeWidth
																			   relatedBy: NSLayoutRelationGreaterThanOrEqual
																				  toItem: nil
																			   attribute: NSLayoutAttributeNotAnAttribute
																			  multiplier: 1.0f
																				constant: kFailedAttemptLabelWidth];
	NSLayoutConstraint *failedAttemptLabelHeight = [NSLayoutConstraint constraintWithItem: _failedAttemptLabel
																				attribute: NSLayoutAttributeHeight
																				relatedBy: NSLayoutRelationEqual
																				   toItem: nil
																				attribute: NSLayoutAttributeNotAnAttribute
																			   multiplier: 1.0f
																				 constant: kFailedAttemptLabelHeight + 6.0f];
	[view addConstraint:failedAttemptLabelCenterX];
	[view addConstraint:failedAttemptLabelCenterY];
	[view addConstraint:failedAttemptLabelWidth];
	[view addConstraint:failedAttemptLabelHeight];
}

- (void)cancelAndDismissMe {
	_isCurrentlyOnScreen = NO;
	[_passcodeTextField resignFirstResponder];
	_isUserBeingAskedForNewPasscode = NO;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	_isUserTurningPasscodeOff = NO;
	[self resetUI];
	
	if ([self.passwordHandler respondsToSelector: @selector(passcodeViewControllerWasDismissed)])
		[self.passwordHandler performSelector: @selector(passcodeViewControllerWasDismissed)];
	// Or, if you prefer by notifications:
    //	[[NSNotificationCenter defaultCenter] postNotificationName: @"dismissPasscodeViewController"
    //														object: self
    //													  userInfo: nil];
	[self dismissViewControllerAnimated: YES completion: nil];
}


- (void)dismissMe {
    // Nullify the cancel button
    self.navigationItem.rightBarButtonItem = nil;
    
	_isCurrentlyOnScreen = NO;
	[self resetUI];
	[_passcodeTextField resignFirstResponder];
	[UIView animateWithDuration: kLockAnimationDuration animations: ^{
		if (_beingDisplayedAsLockScreen) {
			if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
				self.view.center = CGPointMake(self.view.center.x * -1.f, self.view.center.y);
			}
			else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
				self.view.center = CGPointMake(self.view.center.x * 2.f, self.view.center.y);
			}
			else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
				self.view.center = CGPointMake(self.view.center.x, self.view.center.y * -1.f);
			}
			else {
				self.view.center = CGPointMake(self.view.center.x, self.view.center.y * 2.f);
			}
		}
		
	} completion: ^(BOOL finished) {
		if ([self.passwordHandler respondsToSelector: @selector(passcodeViewControllerWasDismissed)])
			[self.passwordHandler performSelector: @selector(passcodeViewControllerWasDismissed)];
		// Or, if you prefer by notifications:
        //		[[NSNotificationCenter defaultCenter] postNotificationName: @"dismissPasscodeViewController"
        //															object: self
        //														  userInfo: nil];
		if (_beingDisplayedAsLockScreen) {
			[self.view removeFromSuperview];
			[self removeFromParentViewController];
		}
		else {
			[self dismissViewControllerAnimated: YES completion: nil];
		}
	}];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarOrientationNotification
												  object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarFrameNotification
												  object: nil];
}


- (void)prepareNavigationControllerWithController:(UIViewController *)viewController {
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: self];
	
	// Customize navigation bar
	// Make sure UITextAttributeTextColor is not set to nil
	// And barTintColor is only called on iOS7+
	navController.navigationBar.tintColor           = self.navigationTintColor;
	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		navController.navigationBar.barTintColor        = self.navigationBarTintColor;
	}
	if (self.navigationTitleColor) {
		navController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : self.navigationTitleColor};
	}
	
	[viewController presentViewController: navController animated: YES completion: nil];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
																						   target: self
																						   action: @selector(cancelAndDismissMe)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString: @"\n"]) return NO;
	
	NSString *typedString = [textField.text stringByReplacingCharactersInRange: range
																	withString: string];
    
    NSLog(@"%@", typedString);
	if (typedString.length >= 1) _firstDigitTextField.secureTextEntry = YES;
	else _firstDigitTextField.secureTextEntry = NO;
	if (typedString.length >= 2) _secondDigitTextField.secureTextEntry = YES;
	else _secondDigitTextField.secureTextEntry = NO;
	if (typedString.length >= 3) _thirdDigitTextField.secureTextEntry = YES;
	else _thirdDigitTextField.secureTextEntry = NO;
	if (typedString.length == 4) _fourthDigitTextField.secureTextEntry = YES;
	else _fourthDigitTextField.secureTextEntry = NO;
	
	if (typedString.length == 4)
    {
		self.isPasswordSuccessful=[self.passwordHandler triageViewController:self verifyPassword:typedString];
        
        
        if(self.isPasswordSuccessful){
            //refresh mainview
            self.view=self.currentView;
        }
        else
            [self denyAccess];
        
        return NO;
    } else
        return YES;
}



- (void)resetTextFields {
	if (![_passcodeTextField isFirstResponder])
		[_passcodeTextField becomeFirstResponder];
	_firstDigitTextField.secureTextEntry = NO;
	_secondDigitTextField.secureTextEntry = NO;
	_thirdDigitTextField.secureTextEntry = NO;
	_fourthDigitTextField.secureTextEntry = NO;
}


- (void)resetUI {
	[self resetTextFields];
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttempts = 0;
	_failedAttemptLabel.hidden = YES;
	_passcodeTextField.text = @"";
	if (_isUserConfirmingPasscode) {
		if (_isUserEnablingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your passcode", @"");
		else if (_isUserChangingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your new passcode", @"");
	}
	else if (_isUserBeingAskedForNewPasscode) {
		if (_isUserEnablingPasscode || _isUserChangingPasscode) {
			_enterPasscodeLabel.text = NSLocalizedString(@"Enter your new passcode", @"");
		}
	}
	else _enterPasscodeLabel.text = NSLocalizedString(@"Enter your passcode", @"");
}


- (void)denyAccess {
	[self resetTextFields];
	_passcodeTextField.text = @"";
	_failedAttempts++;
	
	if (kMaxNumberOfAllowedFailedAttempts > 0 &&
		_failedAttempts == kMaxNumberOfAllowedFailedAttempts &&
		[self.passwordHandler respondsToSelector: @selector(maxNumberOfFailedAttemptsReached)])
		[self.passwordHandler maxNumberOfFailedAttemptsReached];
    //	Or, if you prefer by notifications:
    //	[[NSNotificationCenter defaultCenter] postNotificationName: @"maxNumberOfFailedAttemptsReached"
    //														object: self
    //													  userInfo: nil];
	
	if (_failedAttempts == 1) _failedAttemptLabel.text = NSLocalizedString(@"1 Passcode Failed Attempt", @"");
	else {
		_failedAttemptLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%i Passcode Failed Attempts", @""), _failedAttempts];
	}
	_failedAttemptLabel.layer.cornerRadius = kFailedAttemptLabelHeight * 0.65f;
	_failedAttemptLabel.hidden = NO;
}

    

@end
