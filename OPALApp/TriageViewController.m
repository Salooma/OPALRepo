//
//  TriageViewController.m
//  OPALApp
//


#import "TriageViewController.h"
#import "ThemeFactory.h"
#import "SFHFKeychainUtils.h"
#import "PasswordHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface TriageViewController ()

// The current view displayed on the screen
@property (nonatomic, strong) UIView *currentView;

// The segment control that handles views in the non-password view
@property (nonatomic, strong) UISegmentedControl *segmentControl;

// A control to notify the controller if the password was entered succesfully
@property (nonatomic, assign) BOOL isPasswordSuccessful;

// Gesture recognizers to handle keyboard dismissal and arrival
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

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
    // Our beautiful ivars
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
    int hours, minutes, seconds;
    int secondsLeft;
}

@synthesize myCounterLabel;

#pragma mark - View Management
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the password handler if not already defined
    if (!self.passwordHandler)
        self.passwordHandler = [[PasswordHandler alloc] init];
    
    // Set up the segmented control with the method: switchView: passing itself as a parameter
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Queue", @"Medical"]];
    [self.segmentControl addTarget:self
                            action:@selector(switchView:)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Assign the currentView to the view controller's view
    self.view = self.currentView;
    
    [self applyTheme];
}

- (void)addConstraintsForView:(UIView *)view
{
    // MARK: Please read
	// The controller works properly on all devices and orientations, but looks odd on iPhone's landscape.
	// Usually, lockscreens on iPhone are kept portrait-only, though. It also doesn't fit inside a modal when landscape.
	// That's why only portrait is selected for iPhone's supported orientations.
	// Modify this to fit your needs.
	
	CGFloat yOffsetFromCenter = -view.frame.size.height * 0.24;
	NSLayoutConstraint *enterPasscodeConstraintCenterX = [NSLayoutConstraint constraintWithItem:_enterPasscodeLabel
																					  attribute:NSLayoutAttributeCenterX
																					  relatedBy:NSLayoutRelationEqual
																						 toItem:view
																					  attribute:NSLayoutAttributeCenterX
																					 multiplier:1.0f
																					   constant:0.0f];
	NSLayoutConstraint *enterPasscodeConstraintCenterY = [NSLayoutConstraint constraintWithItem:_enterPasscodeLabel
																					  attribute:NSLayoutAttributeCenterY
																					  relatedBy:NSLayoutRelationEqual
																						 toItem:view
																					  attribute:NSLayoutAttributeCenterY
																					 multiplier:1.0f
																					   constant:yOffsetFromCenter];
    [view addConstraint: enterPasscodeConstraintCenterX];
    [view addConstraint: enterPasscodeConstraintCenterY];
	
	NSLayoutConstraint *firstDigitX = [NSLayoutConstraint constraintWithItem:_firstDigitTextField
																   attribute:NSLayoutAttributeLeft
																   relatedBy:NSLayoutRelationEqual
																	  toItem:view
																   attribute:NSLayoutAttributeCenterX
																  multiplier:1.0f
																	constant:- kHorizontalGap * 1.5f - 2.0f];
	NSLayoutConstraint *secondDigitX = [NSLayoutConstraint constraintWithItem:_secondDigitTextField
																	attribute:NSLayoutAttributeLeft
																	relatedBy:NSLayoutRelationEqual
																	   toItem:view
																	attribute:NSLayoutAttributeCenterX
																   multiplier:1.0f
																	 constant:- kHorizontalGap * 2/3 - 2.0f];
	NSLayoutConstraint *thirdDigitX = [NSLayoutConstraint constraintWithItem:_thirdDigitTextField
																   attribute:NSLayoutAttributeLeft
																   relatedBy:NSLayoutRelationEqual
																	  toItem:view
																   attribute:NSLayoutAttributeCenterX
																  multiplier:1.0f
																	constant:kHorizontalGap * 1/6 - 2.0f];
	NSLayoutConstraint *fourthDigitX = [NSLayoutConstraint constraintWithItem:_fourthDigitTextField
																	attribute:NSLayoutAttributeLeft
																	relatedBy:NSLayoutRelationEqual
																	   toItem:view
																	attribute:NSLayoutAttributeCenterX
																   multiplier:1.0f
																	 constant:kHorizontalGap - 2.0f];
	NSLayoutConstraint *firstDigitY = [NSLayoutConstraint constraintWithItem:_firstDigitTextField
																   attribute:NSLayoutAttributeCenterY
																   relatedBy:NSLayoutRelationEqual
																	  toItem:_enterPasscodeLabel
																   attribute:NSLayoutAttributeBottom
																  multiplier:1.0f
																	constant:kVerticalGap];
	NSLayoutConstraint *secondDigitY = [NSLayoutConstraint constraintWithItem:_secondDigitTextField
																	attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:_enterPasscodeLabel
																	attribute:NSLayoutAttributeBottom
																   multiplier:1.0f
																	 constant:kVerticalGap];
	NSLayoutConstraint *thirdDigitY = [NSLayoutConstraint constraintWithItem:_thirdDigitTextField
																   attribute:NSLayoutAttributeCenterY
																   relatedBy:NSLayoutRelationEqual
																	  toItem:_enterPasscodeLabel
																   attribute:NSLayoutAttributeBottom
																  multiplier:1.0f
																	constant:kVerticalGap];
	NSLayoutConstraint *fourthDigitY = [NSLayoutConstraint constraintWithItem:_fourthDigitTextField
																	attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:_enterPasscodeLabel
																	attribute:NSLayoutAttributeBottom
																   multiplier:1.0f
																	 constant:kVerticalGap];
	[view addConstraint:firstDigitX];
	[view addConstraint:secondDigitX];
	[view addConstraint:thirdDigitX];
	[view addConstraint:fourthDigitX];
	[view addConstraint:firstDigitY];
	[view addConstraint:secondDigitY];
	[view addConstraint:thirdDigitY];
	[view addConstraint:fourthDigitY];
	
    NSLayoutConstraint *failedAttemptLabelCenterX = [NSLayoutConstraint constraintWithItem:_failedAttemptLabel
																				 attribute:NSLayoutAttributeCenterX
																				 relatedBy:NSLayoutRelationEqual
																					toItem:view
																				 attribute:NSLayoutAttributeCenterX
																				multiplier:1.0f
																				  constant:0.0f];
	NSLayoutConstraint *failedAttemptLabelCenterY = [NSLayoutConstraint constraintWithItem:_failedAttemptLabel
																				 attribute:NSLayoutAttributeCenterY
																				 relatedBy:NSLayoutRelationEqual
																					toItem:_enterPasscodeLabel
																				 attribute:NSLayoutAttributeBottom
																				multiplier:1.0f
																				  constant:kVerticalGap * kModifierForBottomVerticalGap - 2.0f];
	NSLayoutConstraint *failedAttemptLabelWidth = [NSLayoutConstraint constraintWithItem:_failedAttemptLabel
																			   attribute:NSLayoutAttributeWidth
																			   relatedBy:NSLayoutRelationGreaterThanOrEqual
																				  toItem:nil
																			   attribute:NSLayoutAttributeNotAnAttribute
																			  multiplier:1.0f
																				constant:kFailedAttemptLabelWidth];
	NSLayoutConstraint *failedAttemptLabelHeight = [NSLayoutConstraint constraintWithItem:_failedAttemptLabel
																				attribute:NSLayoutAttributeHeight
																				relatedBy:NSLayoutRelationEqual
																				   toItem:nil
																				attribute:NSLayoutAttributeNotAnAttribute
																			   multiplier:1.0f
																				 constant:kFailedAttemptLabelHeight + 6.0f];
	[view addConstraint:failedAttemptLabelCenterX];
	[view addConstraint:failedAttemptLabelCenterY];
	[view addConstraint:failedAttemptLabelWidth];
	[view addConstraint:failedAttemptLabelHeight];
}

- (void)resetUI
{
	[self resetTextFields];
    
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttempts = 0;
	_failedAttemptLabel.hidden = YES;
	_passcodeTextField.text = @"";
	
    if (_isUserConfirmingPasscode) {
		if (_isUserEnablingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your passcode", @"");
		else if (_isUserChangingPasscode) _enterPasscodeLabel.text = NSLocalizedString(@"Re-enter your new passcode", @"");
	} else if (_isUserBeingAskedForNewPasscode) {
		if (_isUserEnablingPasscode || _isUserChangingPasscode) {
			_enterPasscodeLabel.text = NSLocalizedString(@"Enter your new passcode", @"");
		}
	} else
        _enterPasscodeLabel.text = NSLocalizedString(@"Enter your passcode", @"");
}

#pragma mark - Theme Management
- (void)applyTheme
{
    id <Theme> themeSetter = [[ThemeFactory sharedThemeFactory] buildThemeForSettingsKey];
    [themeSetter themeNavigationBar:self.navigationController.navigationBar];
    [themeSetter themeTabBar:self.tabBarController.tabBar];
}

#pragma mark - View Accessors
- (UIView *)currentView
{
    // Ternary goodies
    return self.isPasswordSuccessful ? [self mainView] : [self passwordView];
}

- (UIView *)mainView
{
    // Eliminate gesture recognizer
    self.tapRecognizer = nil;
    
    UIView *mainView = [[UIView alloc] init];
    mainView.frame = [UIScreen mainScreen].bounds;
    mainView.backgroundColor = kBackgroundColor;
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 1)];
//    lineView.backgroundColor = [UIColor blackColor];
//    [mainView addSubview:lineView];
    
    self.segmentControl.frame = CGRectMake(mainView.center.x-150.0f, mainView.center.y-215.0f, 300.0f, 30.0f);
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"You are currently:";
    label1.frame = CGRectMake(mainView.center.x-75.0f, mainView.center.y-190.0f, 150.0f, 50.0f);
   
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"in line.";
    label2.frame = CGRectMake(mainView.center.x-35.0f, mainView.center.y+10.0f, 150.0f, 50.0f);
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"Estimated Wait Time";
    label3.frame = CGRectMake(mainView.center.x-95.0f, mainView.center.y+70.0f, 200.0f, 50.0f);
    //label3.font =[label3.font fontWithSize:20];
    label3.textColor = [UIColor redColor];
    label3.font = [UIFont boldSystemFontOfSize:20.0f];
    
    UILabel *label4 = [[UILabel alloc] init];
    label4.text = @"30:58";
    label4.frame = CGRectMake(mainView.center.x-50.0f, mainView.center.y+105.0f, 100.0f, 50.0f);
    label4.font =[label4.font fontWithSize:35];
    label4.textColor = [UIColor redColor];
    
//    [[UIColor blackColor] setFill];
//    UIRectFill((CGRect){0,200,rect.size.width,1});
  
    
//    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
//    overlayView.backgroundColor = [UIColor blackColor];
//    overlayView.alpha = 0.4;
//    [mainView addSubview:overlayView];
//    [overlayView release];
    
    secondsLeft=16925;
    [self countdownTimer];
    
//    NSTimeInterval t = 10000;
//    printf( "%02d:%02d:%02d\n", (int)t/(60*60), ((int)t/60)%60, ((int)t)%60 );
    
    // Add the subviews
    [mainView addSubview:self.segmentControl];
    [mainView addSubview:label1];
    [mainView addSubview:label2];
    [mainView addSubview:label3];
    [mainView addSubview:label4];
    
    return mainView;
    
}

- (UIView *)medicalView
{
    UIView *medicalView = [[UIView alloc] init];
    medicalView.frame = [UIScreen mainScreen].bounds;
    medicalView.backgroundColor = kBackgroundColor;
    
    self.segmentControl.frame = CGRectMake(medicalView.center.x-150.0f, medicalView.center.y-215.0f, 300.0f, 30.0f);
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"Describe how you are feeling:";
    label1.frame = CGRectMake(medicalView.center.x-115.0f, medicalView.center.y-190.0f, 230.0f, 50.0f);
    
    UITextField *text1 = [[UITextField alloc] init];
    text1.frame=CGRectMake(medicalView.center.x-150.0f, medicalView.center.y-150.0f, 300.0f, 100.0f);
    text1.borderStyle=UITextBorderStyleRoundedRect;
    text1.font = [UIFont systemFontOfSize:15];
    text1.placeholder=@"Discuss symptoms or general concerns.";
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeCustom];
    submit.frame = CGRectMake(medicalView.center.x-100.0f, medicalView.center.y+170.0f, 200.0f, 40.0f);
    [submit setTitle:@"Submit" forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 15.0f];
    submit.titleLabel.textColor= [UIColor redColor];
    [[submit layer] setBorderWidth:2.0f];
    [[submit layer] setBorderColor:[UIColor redColor].CGColor];
    //[submit addTarget:self action:@selector(callDeny) forControlEvents:UIControlEventTouchUpInside];
    
    
//    text1.returnKeyType = UIReturnKeyDone;
//    text1.clearButtonMode = UITextFieldViewModeWhileEditing;
//    text1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    // Add subviews
    [medicalView addSubview:self.segmentControl];
    [medicalView addSubview:label1];
    [medicalView addSubview:text1];
    [medicalView addSubview:submit];
    
    
    // Assign the cancel button to the right bar button item in the navigation item
    //[self addCancelButton];
    
    // Add tap gesture recognizer
//    if (!self.tapRecognizer)
//        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                     action:@selector(handleTap:)];
//    
//    
//    // Add tag to animatingView so we know when it is tapped
//    [medicalView addGestureRecognizer:self.tapRecognizer];
    

    
    return medicalView;
    
}

- (UIView *)passwordView
{
    UIView *passwordView = [[UIView alloc] init];
    passwordView.frame = [UIScreen mainScreen].bounds;
    passwordView.backgroundColor = kBackgroundColor;
    
    _failedAttempts = 0;
	_animatingView = [[UIView alloc] initWithFrame:self.view.frame];
	[passwordView addSubview:_animatingView];
	
	_enterPasscodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_enterPasscodeLabel.backgroundColor = kEnterPasscodeLabelBackgroundColor;
	_enterPasscodeLabel.textColor = kLabelTextColor;
	_enterPasscodeLabel.font = kLabelFont;
	_enterPasscodeLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview:_enterPasscodeLabel];
	
	// It is also used to display the "Passcodes did not match" error message if the user fails to confirm the passcode.
	_failedAttemptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_failedAttemptLabel.text = @"1 Passcode Failed Attempt";
	_failedAttemptLabel.backgroundColor	= kFailedAttemptLabelBackgroundColor;
	_failedAttemptLabel.hidden = YES;
	_failedAttemptLabel.textColor = kFailedAttemptLabelTextColor;
	_failedAttemptLabel.font = kLabelFont;
	_failedAttemptLabel.textAlignment = NSTextAlignmentCenter;
	[_animatingView addSubview:_failedAttemptLabel];
	
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
	
	_enterPasscodeLabel.text = _isUserChangingPasscode ? NSLocalizedString(@"Enter your old passcode", @"") :
                                                         NSLocalizedString(@"Enter your passcode", @"");
	
	_enterPasscodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_failedAttemptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _firstDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_secondDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_thirdDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
	_fourthDigitTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraintsForView:(passwordView)];
    
    // Assign the cancel button to the right bar button item in the navigation item
    [self addCancelButton];
    
    // Add tap gesture recognizer
    if (!self.tapRecognizer)
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(handleTap:)];

    
    // Add tag to animatingView so we know when it is tapped
    [passwordView addGestureRecognizer:self.tapRecognizer];
    
    return passwordView;
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 ){
        secondsLeft -- ;
        hours = secondsLeft / 3600;
        minutes = (secondsLeft % 3600) / 60;
        seconds = (secondsLeft %3600) % 60;
        myCounterLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else{
        secondsLeft = 16925;
    }
}

-(void)countdownTimer{
    
    secondsLeft = hours = minutes = seconds = 0;
    if([timer isValid])
    {
        //NSString *result = nil;
        [timer release];
        //[self.view addSubview:timer];
//        result = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        
    }
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
        [pool release];
    
    
//    else
//    {
//     result = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
//    }
    

}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    
//    // Draw them with a 2.0 stroke width so they are a bit more visible.
//    CGContextSetLineWidth(context, 2.0);
//    
//    CGContextMoveToPoint(context, 0,0); //start at this point
//    
//    CGContextAddLineToPoint(context, 20, 20); //draw to this point
//    
//    // and now draw the Path!
//    CGContextStrokePath(context);
//}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([_passcodeTextField isFirstResponder]) {
            [_passcodeTextField resignFirstResponder];
            [self removeCancelButton];
        } else {
            [_passcodeTextField becomeFirstResponder];
            [self addCancelButton];
        }
    }
}

#pragma mark - Bar Button Item Management
- (void)addCancelButton
{
    // Create Cancel UIBarButtonItem
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(dismissMe)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)removeCancelButton
{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - UISegmenetedControl Target Action Method
- (void)switchView: (UISegmentedControl *)segment
{
    NSLog(@"switching views");
    //if index at 1, then don't change anything (from mainview), if index at 2 then switch to medicalView
    switch (segment.selectedSegmentIndex) {
        case 0:
            self.view = [self mainView];
            break;
        
        case 1:
            self.view = [self medicalView];
            break;
        
        default:
            break;
    }
}

#pragma mark - Password View End of Life
- (void)cancelAndDismissMe {
	_isCurrentlyOnScreen = NO;
	[_passcodeTextField resignFirstResponder];
	_isUserBeingAskedForNewPasscode = NO;
	_isUserChangingPasscode = NO;
	_isUserConfirmingPasscode = NO;
	_isUserEnablingPasscode = NO;
	_isUserTurningPasscodeOff = NO;
    
	[self resetUI];

	[self dismissViewControllerAnimated: YES completion: nil];
}


- (void)dismissMe {
    // Nullify the cancel button
    [self removeCancelButton];
    
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
		if (_beingDisplayedAsLockScreen) {
			[self.view removeFromSuperview];
			[self removeFromParentViewController];
		}
		else {
			[self dismissViewControllerAnimated: YES completion: nil];
		}
	}];
    
    // Deregister for UIApplicationNotifications
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarOrientationNotification
												  object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: UIApplicationDidChangeStatusBarFrameNotification
												  object: nil];
}

#pragma mark - Navigation Controller Segue-ing
- (void)prepareNavigationControllerWithController:(UIViewController *)viewController {
    
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
	
	// Customize navigation bar
	// Make sure UITextAttributeTextColor is not set to nil
	// And barTintColor is only called on iOS7+
	navController.navigationBar.tintColor = self.navigationTintColor;
    
	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		navController.navigationBar.barTintColor = self.navigationBarTintColor;
	}
    
	if (self.navigationTitleColor) {
		navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.navigationTitleColor};
	}
	
	[viewController presentViewController: navController animated: YES completion: nil];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						   target:self
																						   action:@selector(cancelAndDismissMe)];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString: @"\n"])
        return NO;
	
	NSString *typedString = [textField.text stringByReplacingCharactersInRange: range
																	withString: string];
    
	if (typedString.length >= 1)
        _firstDigitTextField.secureTextEntry = YES;
	else
        _firstDigitTextField.secureTextEntry = NO;
    
	if (typedString.length >= 2)
        _secondDigitTextField.secureTextEntry = YES;
	else
        _secondDigitTextField.secureTextEntry = NO;
    
	if (typedString.length >= 3)
        _thirdDigitTextField.secureTextEntry = YES;
	else
        _thirdDigitTextField.secureTextEntry = NO;
	
    if (typedString.length == 4)
        _fourthDigitTextField.secureTextEntry = YES;
	else
        _fourthDigitTextField.secureTextEntry = NO;
	
	if (typedString.length == 4) {
        
        // Verify the password
		self.isPasswordSuccessful = [self.passwordHandler triageViewController:self
                                                                verifyPassword:typedString];
        
        
        if (self.isPasswordSuccessful) {
            // Refresh mainView
            [self removeCancelButton];
            self.view = self.currentView;
        }
        else
            [self denyAccess];
        
        // Don't change the text
        return NO;
    } else
        return YES;
}

#pragma mark - Text Field Helpers
- (void)resetTextFields {
    
	if (![_passcodeTextField isFirstResponder])
		[_passcodeTextField becomeFirstResponder];
    
	_firstDigitTextField.secureTextEntry = NO;
	_secondDigitTextField.secureTextEntry = NO;
	_thirdDigitTextField.secureTextEntry = NO;
	_fourthDigitTextField.secureTextEntry = NO;
}

#pragma mark - Password Management
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
